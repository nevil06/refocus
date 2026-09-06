package com.refocusagain.refocus_again.blocking

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.refocusagain.refocus_again.ui.BlockActivity

/**
 * Central blocking enforcement.
 *
 * HARD RULES (do not weaken):
 * 1. A blocked app must never remain in the foreground during an active session.
 * 2. Enforcement is attempted from the AccessibilityService context whenever
 *    available, because Android 10+ forbids background activity launches from a
 *    plain Service. Launching the shield from a background Service silently
 *    fails, which is why blocking used to be inconsistent.
 * 3. If the shield cannot be shown, or the blocked app is STILL foreground a
 *    moment later, we fall back to performGlobalAction(GLOBAL_ACTION_HOME).
 *    That always works from an accessibility service and guarantees the app is
 *    removed from the screen.
 * 4. System-critical packages are never blocked.
 */
object BlockController {
    private const val TAG = "BlockController"

    /** Set by [BlockActivity] so we know whether the shield is actually on screen. */
    @Volatile
    var isShieldVisible = false

    private var lastBlockedPackage: String? = null
    private var lastBlockTimestamp: Long = 0L

    // Only used to avoid launching the shield many times per second while it is
    // already visible. It never suppresses enforcement when the shield is down.
    private const val RELAUNCH_THROTTLE_MS = 350L

    // How long to wait before verifying the blocked app actually went away.
    private const val VERIFY_DELAY_MS = 700L

    private val handler = Handler(Looper.getMainLooper())

    // Critical system packages that must NEVER be blocked under any circumstance.
    private val SYSTEM_EXEMPT_PACKAGES = setOf(
        "com.refocusagain.refocus_again",
        "android",
        "com.android.systemui",
        "com.android.settings",
        "com.android.phone",
        "com.android.server.telecom",
        "com.google.android.dialer",
        "com.samsung.android.incallui",
        "com.samsung.android.dialer",
        "com.android.emergency",
        "com.google.android.packageinstaller",
        "com.android.packageinstaller",
        "com.android.launcher",
        "com.android.launcher3",
        "com.google.android.apps.nexuslauncher",
        "com.android.inputmethod.latin",
        "com.google.android.inputmethod.latin"
    )

    /** True when the package must not be touched by the blocker. */
    fun isExempt(packageName: String?): Boolean {
        if (packageName.isNullOrBlank()) return true
        if (SYSTEM_EXEMPT_PACKAGES.contains(packageName)) return true
        // Never block the active launcher / home app, whatever it is.
        return packageName.contains("launcher", ignoreCase = true)
    }

    /**
     * Enforcement entry point.
     *
     * @param service the accessibility service, when the caller has one. Passing
     *   it enables reliable activity launches and the hard HOME fallback.
     */
    fun checkAndBlock(
        context: Context,
        packageName: String?,
        service: AccessibilityService? = null
    ): Boolean {
        if (isExempt(packageName)) return false
        val pkg = packageName ?: return false

        if (!SessionStateManager.isSessionActive(context)) return false
        if (!SessionStateManager.isPackageBlocked(context, pkg)) return false

        val now = System.currentTimeMillis()
        val sameAsLast = pkg == lastBlockedPackage
        val withinThrottle = (now - lastBlockTimestamp) < RELAUNCH_THROTTLE_MS

        // Rule 1: if the shield is already up for this app and we just handled it,
        // do not spam re-launches. Any other case re-asserts immediately.
        if (isShieldVisible && sameAsLast && withinThrottle) return true

        lastBlockedPackage = pkg
        lastBlockTimestamp = now

        val isStrict = SessionStateManager.isStrict(context)
        showShield(context, pkg, isStrict, service)

        // Rule 3: verify the app actually left the foreground; if not, force HOME.
        if (service != null) {
            handler.postDelayed({ verifyAndHardGuard(context, pkg, service) }, VERIFY_DELAY_MS)
        }
        return true
    }

    private fun showShield(
        context: Context,
        packageName: String,
        isStrict: Boolean,
        service: AccessibilityService?
    ) {
        val appName = try {
            val pm = context.packageManager
            pm.getApplicationLabel(pm.getApplicationInfo(packageName, 0)).toString()
        } catch (_: PackageManager.NameNotFoundException) {
            packageName
        }

        val intent = Intent(context, BlockActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_NO_ANIMATION
            )
            putExtra(BlockActivity.EXTRA_BLOCKED_PACKAGE, packageName)
            putExtra(BlockActivity.EXTRA_BLOCKED_APP_NAME, appName)
            putExtra(BlockActivity.EXTRA_IS_STRICT, isStrict)
        }

        // Rule 2: prefer the accessibility service context. Background activity
        // launches from a plain Service are silently dropped on Android 10+.
        val launcher: Context = service ?: context
        try {
            launcher.startActivity(intent)
        } catch (e: Exception) {
            Log.w(TAG, "Shield launch failed, using HOME guard: ${e.message}")
            hardGuardHome(service)
        }
    }

    /**
     * If the blocked app is still in the foreground after the shield should have
     * appeared, force the user to the home screen. This is the guarantee that a
     * blocked app can never stay on screen.
     */
    private fun verifyAndHardGuard(
        context: Context,
        packageName: String,
        service: AccessibilityService
    ) {
        if (!SessionStateManager.isSessionActive(context)) return

        val current = try {
            service.rootInActiveWindow?.packageName?.toString()
        } catch (_: Exception) {
            null
        }

        if (current == packageName && !isShieldVisible) {
            Log.w(TAG, "Blocked app still foreground, forcing HOME")
            hardGuardHome(service)
        }
    }

    private fun hardGuardHome(service: AccessibilityService?) {
        try {
            service?.performGlobalAction(AccessibilityService.GLOBAL_ACTION_HOME)
        } catch (e: Exception) {
            Log.w(TAG, "HOME guard failed: ${e.message}")
        }
    }

    /** Clears state, e.g. when a session ends. */
    fun reset() {
        lastBlockedPackage = null
        lastBlockTimestamp = 0L
        isShieldVisible = false
        handler.removeCallbacksAndMessages(null)
    }
}
