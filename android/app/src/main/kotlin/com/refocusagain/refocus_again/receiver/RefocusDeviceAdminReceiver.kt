package com.refocusagain.refocus_again.receiver

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.refocusagain.refocus_again.blocking.SessionStateManager

class RefocusDeviceAdminReceiver : DeviceAdminReceiver() {
    companion object {
        private const val TAG = "RefocusDeviceAdmin"
    }

    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
        Log.d(TAG, "Device Admin enabled for Refocus Again")
    }

    override fun onDisableRequested(context: Context, intent: Intent): CharSequence? {
        // During an active protected session, warn the user before allowing deactivation
        if (SessionStateManager.isUninstallProtected(context)) {
            val remaining = SessionStateManager.getRemainingMillis(context)
            val mins = remaining / 60000
            Log.w(TAG, "Device Admin disable requested during active protected session ($mins min remaining)")
            return "Refocus is currently protecting a focus session ($mins min remaining). " +
                    "Disabling Device Admin will end your session protection and allow uninstallation."
        }
        Log.d(TAG, "Device Admin disable requested — no active protected session, allowing")
        return null
    }

    override fun onDisabled(context: Context, intent: Intent) {
        super.onDisabled(context, intent)
        // If Device Admin was forcibly deactivated during a protected session,
        // clear the protection flag (session continues but is no longer protected)
        if (SessionStateManager.isSessionActive(context)) {
            SessionStateManager.setUninstallProtected(context, false)
            Log.w(TAG, "Device Admin disabled during active session — protection flag cleared")
        }
        Log.d(TAG, "Device Admin disabled for Refocus Again")
    }
}
