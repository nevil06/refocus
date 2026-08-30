package com.refocusagain.refocus_again.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.refocusagain.refocus_again.blocking.SessionStateManager
import com.refocusagain.refocus_again.service.FocusBlockerService

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) return

        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON"
        ) {
            if (SessionStateManager.isSessionActive(context)) {
                FocusBlockerService.startService(context)
            }
        }
    }
}
