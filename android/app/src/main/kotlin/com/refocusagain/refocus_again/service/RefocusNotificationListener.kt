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
            if (NotificationBlockController.shouldSuppressNotification(this, sbn)) {
                // Cancel notification so it doesn't distract the user during active focus
                cancelNotification(sbn.key)
                Log.d(TAG, "Cancelled notification for key: ${sbn.key} from ${sbn.packageName}")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error suppressing notification: ${e.message}", e)
        }
    }
}
