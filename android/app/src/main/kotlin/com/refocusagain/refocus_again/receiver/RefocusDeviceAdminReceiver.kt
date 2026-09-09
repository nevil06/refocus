package com.refocusagain.refocus_again.receiver

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class RefocusDeviceAdminReceiver : DeviceAdminReceiver() {
    companion object {
        private const val TAG = "RefocusDeviceAdmin"
    }

    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
        Log.d(TAG, "Device Admin enabled for Refocus Again")
    }

    override fun onDisabled(context: Context, intent: Intent) {
        super.onDisabled(context, intent)
        Log.d(TAG, "Device Admin disabled for Refocus Again")
    }
}
