package com.refocusagain.refocus_again.ui

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.refocusagain.refocus_again.MainActivity
import com.refocusagain.refocus_again.R
import com.refocusagain.refocus_again.blocking.SessionStateManager
import java.util.Locale

class BlockActivity : Activity() {

    companion object {
        const val EXTRA_BLOCKED_PACKAGE = "extra_blocked_package"
        const val EXTRA_BLOCKED_APP_NAME = "extra_blocked_app_name"
    }

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var tvRemainingTime: TextView
    private lateinit var tvBlockedAppName: TextView
    private lateinit var ivBlockedAppIcon: ImageView
    private lateinit var btnBackToFocus: View
    private lateinit var btnExitToHome: View

    private val updateTimerRunnable = object : Runnable {
        override fun run() {
            updateRemainingTime()
            handler.postDelayed(this, 1000L)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_block)

        // Set system bars to match deep obsidian neobrutalist background
        window.statusBarColor = ContextCompat.getColor(this, R.color.bg_obsidian)
        window.navigationBarColor = ContextCompat.getColor(this, R.color.bg_obsidian)

        tvBlockedAppName = findViewById(R.id.tvBlockedAppName)
        tvRemainingTime = findViewById(R.id.tvRemainingTime)
        ivBlockedAppIcon = findViewById(R.id.ivBlockedAppIcon)
        btnBackToFocus = findViewById(R.id.btnBackToFocus)
        btnExitToHome = findViewById(R.id.btnExitToHome)

        bindBlockedAppDetails(intent)

        btnBackToFocus.setOnClickListener {
            val mainIntent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
            }
            startActivity(mainIntent)
            finish()
        }

        btnExitToHome.setOnClickListener {
            navigateToHomeLauncher()
        }

        updateRemainingTime()
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        setIntent(intent)
        bindBlockedAppDetails(intent)
        updateRemainingTime()
    }

    private fun bindBlockedAppDetails(intent: Intent?) {
        val appName = intent?.getStringExtra(EXTRA_BLOCKED_APP_NAME) ?: "This application"
        val packageName = intent?.getStringExtra(EXTRA_BLOCKED_PACKAGE)

        tvBlockedAppName.text = "$appName is blocked during your focus session."

        if (!packageName.isNullOrBlank()) {
            try {
                val icon = packageManager.getApplicationIcon(packageName)
                ivBlockedAppIcon.setImageDrawable(icon)
            } catch (_: PackageManager.NameNotFoundException) {
                ivBlockedAppIcon.setImageResource(R.drawable.ic_shield_brutal)
            } catch (_: Exception) {
                ivBlockedAppIcon.setImageResource(R.drawable.ic_shield_brutal)
            }
        } else {
            ivBlockedAppIcon.setImageResource(R.drawable.ic_shield_brutal)
        }
    }

    override fun onResume() {
        super.onResume()
        handler.post(updateTimerRunnable)
    }

    override fun onPause() {
        super.onPause()
        handler.removeCallbacks(updateTimerRunnable)
    }

    private fun updateRemainingTime() {
        val remainingMillis = SessionStateManager.getRemainingMillis(this)
        if (remainingMillis <= 0) {
            // Focus session finished
            handler.removeCallbacks(updateTimerRunnable)
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

    private fun navigateToHomeLauncher() {
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
        finish()
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        // Go back to home launcher, never let back button penetrate to blocked app
        navigateToHomeLauncher()
    }
}
