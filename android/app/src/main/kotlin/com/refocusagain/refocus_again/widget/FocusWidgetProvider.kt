package com.refocusagain.refocus_again.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.widget.RemoteViews
import com.refocusagain.refocus_again.MainActivity
import com.refocusagain.refocus_again.R
import com.refocusagain.refocus_again.blocking.SessionStateManager

/**
 * Home-screen widget showing the current focus session status.
 *
 * When a session is active it renders a live, self-ticking count-down using the
 * RemoteViews Chronometer (base = elapsedRealtime + remaining, countDown = true),
 * so the widget updates every second on its own without waking the app. When idle
 * it shows a "Start Focus" prompt. Tapping the widget opens the app.
 */
class FocusWidgetProvider : AppWidgetProvider() {

    companion object {
        /** Ask the system to redraw all instances of this widget. */
        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, FocusWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            if (ids != null && ids.isNotEmpty()) {
                val intent = Intent(context, FocusWidgetProvider::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                }
                context.sendBroadcast(intent)
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, buildViews(context))
        }
    }

    private fun buildViews(context: Context): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_focus)

        val tapIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pending = PendingIntent.getActivity(
            context,
            0,
            tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widgetRoot, pending)

        val active = SessionStateManager.isSessionActive(context)
        if (active) {
            val remainingMs = SessionStateManager.getRemainingMillis(context)
            val label = SessionStateManager.getLabel(context)

            views.setTextViewText(
                R.id.widgetTitle,
                if (label.isNullOrBlank()) "Focus in progress" else label
            )
            views.setViewVisibility(R.id.widgetChronometer, android.view.View.VISIBLE)
            views.setViewVisibility(R.id.widgetIdleText, android.view.View.GONE)

            // Chronometer counts DOWN from (now + remaining).
            val base = SystemClock.elapsedRealtime() + remainingMs
            views.setChronometer(R.id.widgetChronometer, base, null, true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                views.setChronometerCountDown(R.id.widgetChronometer, true)
            }
        } else {
            views.setTextViewText(R.id.widgetTitle, "Refocus Again")
            views.setViewVisibility(R.id.widgetChronometer, android.view.View.GONE)
            views.setViewVisibility(R.id.widgetIdleText, android.view.View.VISIBLE)
            views.setTextViewText(R.id.widgetIdleText, "Tap to start a focus session")
        }

        return views
    }
}
