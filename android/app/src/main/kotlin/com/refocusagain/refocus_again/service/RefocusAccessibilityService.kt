package com.refocusagain.refocus_again.service

import android.accessibilityservice.AccessibilityService
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import com.refocusagain.refocus_again.blocking.BlockController
import com.refocusagain.refocus_again.blocking.SessionStateManager

/**
 * Foreground-app interceptor and the ONLY component that enforces blocking.
 *
 * Enforcement lives here (not in the foreground Service) because Android 10+
 * silently drops background activity launches from a plain Service, which made
 * blocking inconsistent. An accessibility service can both launch the shield and
 * call performGlobalAction as a hard guard.
 *
 * Privacy: only the package name of the active window is ever read. No screen
 * text, fields, or content is inspected or logged.
 */
class RefocusAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "RefocusAccessibility"

        var isServiceRunning = false
            private set

        @Volatile
        var instance: RefocusAccessibilityService? = null
            private set

        /** Last package seen in the foreground, best effort. */
        @Volatile
        var lastForegroundPackage: String? = null
            private set

        private const val POLL_MS_NORMAL = 700L
        private const val POLL_MS_STRICT = 350L
    }

    private val handler = Handler(Looper.getMainLooper())

    private val watchdog = object : Runnable {
        override fun run() {
            var delay = POLL_MS_NORMAL
            try {
                if (SessionStateManager.isSessionActive(this@RefocusAccessibilityService)) {
                    if (SessionStateManager.isStrict(this@RefocusAccessibilityService)) {
                        delay = POLL_MS_STRICT
                    }
                    val pkg = resolveForegroundPackage()
                    if (pkg != null) {
                        BlockController.checkAndBlock(
                            this@RefocusAccessibilityService,
                            pkg,
                            this@RefocusAccessibilityService
                        )
                    }
                }
            } catch (e: Exception) {
                Log.w(TAG, "watchdog tick failed: ${e.message}")
            }
            handler.postDelayed(this, delay)
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        isServiceRunning = true
        instance = this
        // Own the watchdog here so enforcement always runs from this privileged
        // context, even when a blocked app was already resident in the background.
        handler.removeCallbacks(watchdog)
        handler.post(watchdog)
        Log.d(TAG, "RefocusAccessibilityService connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_WINDOWS_CHANGED,
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                val pkgName = event.packageName?.toString() ?: return
                if (pkgName.isBlank()) return
                lastForegroundPackage = pkgName
                BlockController.checkAndBlock(this, pkgName, this)
            }
        }
    }

    /**
     * Resolves the package that currently owns the active (focused) window. This
     * catches apps that resume from the background without emitting a fresh
     * window-state event. Only the package name is read.
     */
    fun resolveForegroundPackage(): String? {
        return try {
            val fromRoot = rootInActiveWindow?.packageName?.toString()
            if (!fromRoot.isNullOrBlank()) {
                lastForegroundPackage = fromRoot
                return fromRoot
            }
            val active = windows?.firstOrNull { it.isActive }
            val pkg = active?.root?.packageName?.toString()
            if (!pkg.isNullOrBlank()) {
                lastForegroundPackage = pkg
                pkg
            } else {
                lastForegroundPackage
            }
        } catch (e: Exception) {
            Log.w(TAG, "resolveForegroundPackage failed: ${e.message}")
            lastForegroundPackage
        }
    }

    override fun onInterrupt() {
        Log.w(TAG, "RefocusAccessibilityService interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(watchdog)
        isServiceRunning = false
        instance = null
        Log.d(TAG, "RefocusAccessibilityService destroyed")
    }
}
