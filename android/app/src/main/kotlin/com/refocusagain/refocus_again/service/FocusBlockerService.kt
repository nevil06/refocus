package com.refocusagain.refocus_again.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import com.refocusagain.refocus_again.MainActivity
import com.refocusagain.refocus_again.R
import com.refocusagain.refocus_again.blocking.BlockController
import com.refocusagain.refocus_again.blocking.SessionStateManager
import com.refocusagain.refocus_again.widget.FocusWidgetProvider
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import java.util.Locale

class FocusBlockerService : Service() {

    companion object {
        const val CHANNEL_ID = "focus_blocker_channel"
        const val NOTIFICATION_ID = 1001

        const val ACTION_START = "com.refocusagain.action.START_FOCUS"
        const val ACTION_STOP = "com.refocusagain.action.STOP_FOCUS"

        fun startService(context: Context) {
            val intent = Intent(context, FocusBlockerService::class.java).apply {
                action = ACTION_START
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stopService(context: Context) {
            val intent = Intent(context, FocusBlockerService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }
    }

    private val serviceScope = CoroutineScope(Dispatchers.Default + Job())
    private var updateJob: Job? = null
    private var watchdogJob: Job? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopForegroundTask()
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_START, null -> {
                if (SessionStateManager.isSessionActive(this)) {
                    startForegroundTask()
                } else {
                    stopSelf()
                    return START_NOT_STICKY
                }
            }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                getString(R.string.notification_channel_name),
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = getString(R.string.notification_channel_desc)
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(remainingText: String): Notification {
        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val endTime = SessionStateManager.getEndTime(this)
        val label = SessionStateManager.getLabel(this)
        val title = if (label.isNullOrBlank()) "Focus timer running" else "Focusing: $label"

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setSmallIcon(R.drawable.ic_stat_timer)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            // Treat it as a timer so the system renders a timer-style banner.
            .setCategory(NotificationCompat.CATEGORY_STOPWATCH)
            .setColorized(true)
            .setColor(0xFF141414.toInt())
            .addAction(0, "Return to Focus", pendingIntent)

        // Live, self-ticking countdown rendered by the system every second as a
        // timer chronometer, without us having to wake the app. Falls back to
        // static text on very old versions that lack the count-down chronometer.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && endTime > 0L) {
            builder
                .setUsesChronometer(true)
                .setChronometerCountDown(true)
                .setWhen(endTime)
                .setShowWhen(true)
                .setContentText("Time remaining. Distracting apps are blocked.")
        } else {
            builder.setContentText("$remainingText remaining • distracting apps blocked")
        }

        return builder.build()
    }

    private fun startForegroundTask() {
        val remainingMillis = SessionStateManager.getRemainingMillis(this)
        val initialNotification = buildNotification(formatRemaining(remainingMillis))

        val foregroundServiceType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
        } else {
            0
        }

        try {
            ServiceCompat.startForeground(
                this,
                NOTIFICATION_ID,
                initialNotification,
                foregroundServiceType
            )
        } catch (_: Exception) {
            startForeground(NOTIFICATION_ID, initialNotification)
        }

        startPeriodicUpdate()
        startForegroundWatchdog()
        FocusWidgetProvider.refresh(this)
    }

    /**
     * Backup enforcement tick.
     *
     * The primary watchdog lives in RefocusAccessibilityService because Android
     * 10+ silently drops background activity launches from a plain Service, so
     * enforcement must run from the accessibility context. This loop only
     * delegates through that privileged instance; it never launches the shield
     * itself. Keep it as a safety net in case an accessibility event is missed.
     */
    private fun startForegroundWatchdog() {
        watchdogJob?.cancel()
        watchdogJob = serviceScope.launch {
            while (isActive) {
                if (!SessionStateManager.isSessionActive(this@FocusBlockerService)) {
                    break
                }

                val strict = SessionStateManager.isStrict(this@FocusBlockerService)
                val service = RefocusAccessibilityService.instance
                if (service != null) {
                    val fg = service.resolveForegroundPackage()
                    if (fg != null) {
                        // Pass the accessibility service so the shield launch and
                        // the HOME hard guard both work.
                        BlockController.checkAndBlock(service, fg, service)
                    }
                }

                delay(if (strict) 1000L else 2000L)
            }
        }
    }

    private fun startPeriodicUpdate() {
        updateJob?.cancel()
        updateJob = serviceScope.launch {
            while (isActive) {
                delay(15000L) // Refresh notification/widget every 15s to save battery
                if (!SessionStateManager.isSessionActive(this@FocusBlockerService)) {
                    stopForegroundTask()
                    stopSelf()
                    break
                }
                val remaining = SessionStateManager.getRemainingMillis(this@FocusBlockerService)
                val manager = getSystemService(NotificationManager::class.java)
                manager.notify(NOTIFICATION_ID, buildNotification(formatRemaining(remaining)))
                FocusWidgetProvider.refresh(this@FocusBlockerService)
            }
        }
    }

    private fun stopForegroundTask() {
        updateJob?.cancel()
        watchdogJob?.cancel()
        BlockController.reset()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        FocusWidgetProvider.refresh(this)
    }

    private fun formatRemaining(millis: Long): String {
        val totalSec = millis / 1000
        val min = totalSec / 60
        val sec = totalSec % 60
        return String.format(Locale.getDefault(), "%02d:%02d", min, sec)
    }

    override fun onDestroy() {
        super.onDestroy()
        updateJob?.cancel()
        watchdogJob?.cancel()
    }
}
