package com.refocusagain.refocus_again.blocking

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import com.refocusagain.refocus_again.ui.BlockActivity

object BlockController {
    private var lastBlockedPackage: String? = null
    private var lastBlockTimestamp: Long = 0L
    private const val DEBOUNCE_MS = 500L

    // Critical system packages that should NEVER be blocked under any circumstance
    private val SYSTEM_EXEMPT_PACKAGES = setOf(
        "com.refocusagain.refocus_again",
        "android",
        "com.android.systemui",
        "com.android.settings",
        "com.android.phone",
        "com.google.android.dialer",
        "com.samsung.android.incallui",
        "com.android.emergency",
        "com.google.android.packageinstaller"
    )

    fun checkAndBlock(context: Context, packageName: String?): Boolean {
        if (packageName.isNullOrBlank()) return false
        if (SYSTEM_EXEMPT_PACKAGES.contains(packageName)) return false

        val now = System.currentTimeMillis()
        if (packageName == lastBlockedPackage && (now - lastBlockTimestamp) < DEBOUNCE_MS) {
            return true
        }

        if (!SessionStateManager.isSessionActive(context)) {
            return false
        }

        if (!SessionStateManager.isPackageBlocked(context, packageName)) {
            return false
        }

        // App is blocked! Launch BlockActivity
        lastBlockedPackage = packageName
        lastBlockTimestamp = now

        val appName = try {
            val pm = context.packageManager
            val appInfo = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(appInfo).toString()
        } catch (_: PackageManager.NameNotFoundException) {
            packageName
        }

        val intent = Intent(context, BlockActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra(BlockActivity.EXTRA_BLOCKED_PACKAGE, packageName)
            putExtra(BlockActivity.EXTRA_BLOCKED_APP_NAME, appName)
        }

        context.startActivity(intent)
        return true
    }
}
