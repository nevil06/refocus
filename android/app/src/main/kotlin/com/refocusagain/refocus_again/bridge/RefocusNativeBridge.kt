package com.refocusagain.refocus_again.bridge

import android.app.Activity
import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.os.Process
import android.provider.Settings
import android.text.TextUtils
import androidx.core.content.ContextCompat
import com.refocusagain.refocus_again.apps.InstalledAppsProvider
import com.refocusagain.refocus_again.blocking.SessionStateManager
import com.refocusagain.refocus_again.service.FocusBlockerService
import com.refocusagain.refocus_again.service.RefocusAccessibilityService
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class RefocusNativeBridge(private val context: Context, private val activity: Activity?) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.refocusagain.app/bridge"

        fun registerWith(messenger: BinaryMessenger, context: Context, activity: Activity?): RefocusNativeBridge {
            val channel = MethodChannel(messenger, CHANNEL_NAME)
            val bridge = RefocusNativeBridge(context, activity)
            channel.setMethodCallHandler(bridge)
            return bridge
        }
    }

    private val scope = CoroutineScope(Dispatchers.Main)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAccessibilityEnabled" -> {
                result.success(isAccessibilityServiceEnabled())
            }
            "openAccessibilitySettings" -> {
                openAccessibilitySettings()
                result.success(true)
            }
            "getInstalledApps" -> {
                scope.launch {
                    try {
                        val apps = InstalledAppsProvider.getInstalledApps(context)
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("APP_DISCOVERY_ERROR", e.message, null)
                    }
                }
            }
            "startBlocking" -> {
                try {
                    val sessionId = call.argument<String>("sessionId") ?: ""
                    val startTimeEpochMs = (call.argument<Number>("startTimeEpochMs"))?.toLong() ?: System.currentTimeMillis()
                    val endTimeEpochMs = (call.argument<Number>("endTimeEpochMs"))?.toLong() ?: 0L
                    val durationSeconds = (call.argument<Number>("durationSeconds"))?.toLong() ?: 0L
                    val blockedPackages = call.argument<List<String>>("blockedPackages") ?: emptyList()
                    val isStrict = call.argument<Boolean>("isStrict") ?: false
                    val label = call.argument<String>("label")

                    SessionStateManager.saveSession(
                        context,
                        sessionId,
                        startTimeEpochMs,
                        endTimeEpochMs,
                        durationSeconds,
                        blockedPackages,
                        isStrict,
                        label
                    )

                    FocusBlockerService.startService(context)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("START_BLOCKING_ERROR", e.message, null)
                }
            }
            "stopBlocking" -> {
                try {
                    SessionStateManager.clearSession(context)
                    FocusBlockerService.stopService(context)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("STOP_BLOCKING_ERROR", e.message, null)
                }
            }
            "isBlockingActive" -> {
                result.success(SessionStateManager.isSessionActive(context))
            }
            "getActiveSessionState" -> {
                result.success(SessionStateManager.getActiveSessionData(context))
            }
            "isIgnoringBatteryOptimizations" -> {
                result.success(isIgnoringBatteryOptimizations())
            }
            "requestBatteryOptimizationExemption" -> {
                requestBatteryOptimizationExemption()
                result.success(true)
            }
            "hasNotificationPermission" -> {
                result.success(hasNotificationPermission())
            }
            "hasUsageStatsPermission" -> {
                result.success(hasUsageStatsPermission())
            }
            "openUsageStatsSettings" -> {
                openUsageStatsSettings()
                result.success(true)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        if (RefocusAccessibilityService.isServiceRunning) return true

        val expectedServiceName = "${context.packageName}/${RefocusAccessibilityService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServices)

        while (colonSplitter.hasNext()) {
            val componentName = colonSplitter.next()
            if (componentName.equals(expectedServiceName, ignoreCase = true) ||
                componentName.contains(RefocusAccessibilityService::class.java.simpleName)
            ) {
                return true
            }
        }
        return false
    }

    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
            return powerManager?.isIgnoringBatteryOptimizations(context.packageName) == true
        }
        return true
    }

    private fun requestBatteryOptimizationExemption() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:${context.packageName}")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(intent)
            } catch (_: Exception) {
                val fallbackIntent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(fallbackIntent)
            }
        }
    }

    private fun hasNotificationPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(
                context,
                android.Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager ?: return false
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun openUsageStatsSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
    }
}
