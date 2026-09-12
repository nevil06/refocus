package com.refocusagain.refocus_again.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.refocusagain.refocus_again.blocking.SessionStateManager
import com.refocusagain.refocus_again.service.FocusBlockerService

class BootReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "RefocusBootReceiver"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) return

        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON"
        ) {
            if (SessionStateManager.isSessionActive(context)) {
                // Session still active after reboot — restart foreground service
                Log.d(TAG, "Active session found after boot, restarting FocusBlockerService")
                FocusBlockerService.startService(context)
            }
        }
    }
}
