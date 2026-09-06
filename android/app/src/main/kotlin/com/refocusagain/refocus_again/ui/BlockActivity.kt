package com.refocusagain.refocus_again.ui

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import com.refocusagain.refocus_again.MainActivity
import com.refocusagain.refocus_again.R
import com.refocusagain.refocus_again.blocking.BlockController
import com.refocusagain.refocus_again.blocking.SessionStateManager
import java.util.Locale

class BlockActivity : Activity() {

    companion object {
        const val EXTRA_BLOCKED_PACKAGE = "extra_blocked_package"
        const val EXTRA_BLOCKED_APP_NAME = "extra_blocked_app_name"
        const val EXTRA_IS_STRICT = "extra_is_strict"
    }

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var tvRemainingTime: TextView
    private lateinit var tvBlockedAppName: TextView
    private lateinit var btnBackToFocus: Button
    private var isStrict = false

    private val updateTimerRunnable = object : Runnable {
        override fun run() {
            updateRemainingTime()
            handler.postDelayed(this, 1000L)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        isStrict = intent.getBooleanExtra(EXTRA_IS_STRICT, false)
        applyWindowFlags()

        setContentView(R.layout.activity_block)

        tvBlockedAppName = findViewById(R.id.tvBlockedAppName)
        tvRemainingTime = findViewById(R.id.tvRemainingTime)
        btnBackToFocus = findViewById(R.id.btnBackToFocus)

        val appName = intent.getStringExtra(EXTRA_BLOCKED_APP_NAME) ?: "This application"
        tvBlockedAppName.text = "$appName is blocked until your focus session is complete."

        btnBackToFocus.setOnClickListener {
            val mainIntent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
            }
            startActivity(mainIntent)
            finish()
        }

        updateRemainingTime()
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        setIntent(intent)
        isStrict = intent?.getBooleanExtra(EXTRA_IS_STRICT, isStrict) ?: isStrict
        val appName = intent?.getStringExtra(EXTRA_BLOCKED_APP_NAME) ?: "This application"
        tvBlockedAppName.text = "$appName is blocked until your focus session is complete."
        updateRemainingTime()
    }

    /**
     * Ensures the shield reliably covers a blocked app: show over the lock screen
     * and turn the screen on so a resumed background app can never be seen behind
     * it. These are safe in both normal and strict mode.
     */
    private fun applyWindowFlags() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
    }

    override fun onResume() {
        super.onResume()
        BlockController.isShieldVisible = true
        handler.post(updateTimerRunnable)
    }

    override fun onPause() {
        super.onPause()
        BlockController.isShieldVisible = false
        handler.removeCallbacks(updateTimerRunnable)
    }

    private fun updateRemainingTime() {
        val remainingMillis = SessionStateManager.getRemainingMillis(this)
        if (remainingMillis <= 0) {
            // Focus session finished
            finish()
            return
        }

        val totalSeconds = remainingMillis / 1000
        val hours = totalSeconds / 3600
        val minutes = (totalSeconds % 3600) / 60
        val seconds = totalSeconds % 60

        val formattedTime = if (hours > 0) {
            String.format(Locale.getDefault(), "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            String.format(Locale.getDefault(), "%02d:%02d", minutes, seconds)
        }

        tvRemainingTime.text = formattedTime
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        // Go back to home launcher or Refocus Again, never let back button penetrate to blocked app
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
        finish()
    }
}
