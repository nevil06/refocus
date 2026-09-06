package com.refocusagain.refocus_again.blocking

import android.app.Notification
import android.content.Context
import android.service.notification.StatusBarNotification
import android.util.Log

object NotificationBlockController {
    private const val TAG = "NotificationBlockCtrl"
    private const val PREFS_SETTINGS = "refocus_settings_prefs"
    private const val KEY_NOTIFICATION_BLOCKING_ENABLED = "notification_blocking_enabled"

    // Critical system packages that should NEVER have their notifications silenced
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

    fun isNotificationBlockingEnabled(context: Context): Boolean {
        val prefs = context.applicationContext.getSharedPreferences(PREFS_SETTINGS, Context.MODE_PRIVATE)
        return prefs.getBoolean(KEY_NOTIFICATION_BLOCKING_ENABLED, true)
    }

    fun setNotificationBlockingEnabled(context: Context, enabled: Boolean) {
        val prefs = context.applicationContext.getSharedPreferences(PREFS_SETTINGS, Context.MODE_PRIVATE)
        prefs.edit().putBoolean(KEY_NOTIFICATION_BLOCKING_ENABLED, enabled).apply()
    }

    fun shouldSuppressNotification(context: Context, sbn: StatusBarNotification?): Boolean {
        if (sbn == null) return false

        val packageName = sbn.packageName
        if (packageName.isNullOrBlank()) return false

        // 1. Never suppress system, dialer, or emergency packages
        if (SYSTEM_EXEMPT_PACKAGES.contains(packageName)) {
            return false
        }

        val notification = sbn.notification ?: return false

        // 2. Never suppress incoming phone calls or alarms regardless of package
        val category = notification.category
        if (category == Notification.CATEGORY_CALL ||
            category == Notification.CATEGORY_ALARM
        ) {
            return false
        }

        // 3. Never suppress ongoing incoming call / foreground alerts
        if ((notification.flags and Notification.FLAG_ONGOING_EVENT) != 0 &&
            category == Notification.CATEGORY_CALL
        ) {
            return false
        }

        // 4. Check if notification blocking setting is active
        if (!isNotificationBlockingEnabled(context)) {
            return false
        }

        // 5. Check if a focus session is currently active
        if (!SessionStateManager.isSessionActive(context)) {
            return false
        }

        // 6. Check if this specific package is in the blocked apps list
        if (!SessionStateManager.isPackageBlocked(context, packageName)) {
            return false
        }

        Log.d(TAG, "Suppressing notification from blocked package: $packageName")
        return true
    }
}
