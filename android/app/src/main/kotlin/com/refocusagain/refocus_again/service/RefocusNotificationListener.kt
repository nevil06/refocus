package com.refocusagain.refocus_again.service

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import com.refocusagain.refocus_again.blocking.NotificationBlockController

class RefocusNotificationListener : NotificationListenerService() {

    companion object {
        private const val TAG = "RefocusNotifListener"
        var isListenerConnected = false
            private set
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        isListenerConnected = true
        Log.d(TAG, "RefocusNotificationListener connected and ready")
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        isListenerConnected = false
        Log.d(TAG, "RefocusNotificationListener disconnected")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return

        try {
            val pkg = sbn.packageName ?: "unknown"
            val shouldSuppress = NotificationBlockController.shouldSuppressNotification(this, sbn)
            Log.d(TAG, "Incoming notification from '$pkg' -> suppress = $shouldSuppress")

            if (shouldSuppress) {
                // Cancel notification so it doesn't distract the user during active focus
                if (sbn.key != null) {
                    cancelNotification(sbn.key)
                } else {
                    @Suppress("DEPRECATION")
                    cancelNotification(sbn.packageName, sbn.tag, sbn.id)
                }
                Log.d(TAG, "Successfully cancelled notification from '$pkg' (key=${sbn.key})")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error suppressing notification: ${e.message}", e)
        }
    }
}
