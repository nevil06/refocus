package com.refocusagain.refocus_again.service

import android.accessibilityservice.AccessibilityService
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import com.refocusagain.refocus_again.blocking.BlockController

class RefocusAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "RefocusAccessibility"
        var isServiceRunning = false
            private set
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        isServiceRunning = true
        Log.d(TAG, "RefocusAccessibilityService connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_WINDOWS_CHANGED -> {
                val pkgName = event.packageName?.toString()
                if (!pkgName.isNullOrBlank()) {
                    BlockController.checkAndBlock(this, pkgName)
                }
            }
        }
    }

    override fun onInterrupt() {
        Log.w(TAG, "RefocusAccessibilityService interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        isServiceRunning = false
        Log.d(TAG, "RefocusAccessibilityService destroyed")
    }
}
