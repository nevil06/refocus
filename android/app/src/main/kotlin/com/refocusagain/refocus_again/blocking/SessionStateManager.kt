package com.refocusagain.refocus_again.blocking

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray

object SessionStateManager {
    private const val PREFS_NAME = "refocus_session_prefs"
    private const val KEY_SESSION_ID = "refocus_session_id"
    private const val KEY_START_TIME = "refocus_start_time"
    private const val KEY_END_TIME = "refocus_end_time"
    private const val KEY_DURATION_SECONDS = "refocus_duration_seconds"
    private const val KEY_BLOCKED_PACKAGES = "refocus_blocked_packages"
    private const val KEY_IS_STRICT = "refocus_is_strict"
    private const val KEY_IS_ACTIVE = "refocus_is_active"
    private const val KEY_SESSION_LABEL = "refocus_session_label"

    private fun getPrefs(context: Context): SharedPreferences {
        return context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    fun saveSession(
        context: Context,
        sessionId: String,
        startTimeEpochMs: Long,
        endTimeEpochMs: Long,
        durationSeconds: Long,
        blockedPackages: List<String>,
        isStrict: Boolean,
        label: String? = null
    ) {
        val jsonArray = JSONArray(blockedPackages)
        getPrefs(context).edit().apply {
            putString(KEY_SESSION_ID, sessionId)
            putLong(KEY_START_TIME, startTimeEpochMs)
            putLong(KEY_END_TIME, endTimeEpochMs)
            putLong(KEY_DURATION_SECONDS, durationSeconds)
            putString(KEY_BLOCKED_PACKAGES, jsonArray.toString())
            putBoolean(KEY_IS_STRICT, isStrict)
            putBoolean(KEY_IS_ACTIVE, true)
            putString(KEY_SESSION_LABEL, label ?: "")
            apply()
        }
    }

    fun clearSession(context: Context) {
        getPrefs(context).edit().apply {
            putBoolean(KEY_IS_ACTIVE, false)
            putString(KEY_SESSION_ID, "")
            putLong(KEY_START_TIME, 0L)
            putLong(KEY_END_TIME, 0L)
            putString(KEY_BLOCKED_PACKAGES, "[]")
            putBoolean(KEY_IS_STRICT, false)
            putString(KEY_SESSION_LABEL, "")
            apply()
        }
    }

    fun isSessionActive(context: Context): Boolean {
        val prefs = getPrefs(context)
        val isActive = prefs.getBoolean(KEY_IS_ACTIVE, false)
        if (!isActive) return false

        val endTime = prefs.getLong(KEY_END_TIME, 0L)
        val now = System.currentTimeMillis()
        if (now >= endTime) {
            // Session expired naturally
            clearSession(context)
            return false
        }
        return true
    }

    fun getRemainingMillis(context: Context): Long {
        val prefs = getPrefs(context)
        if (!prefs.getBoolean(KEY_IS_ACTIVE, false)) return 0L
        val endTime = prefs.getLong(KEY_END_TIME, 0L)
        val remaining = endTime - System.currentTimeMillis()
        return if (remaining > 0) remaining else 0L
    }

    fun getEndTime(context: Context): Long {
        return getPrefs(context).getLong(KEY_END_TIME, 0L)
    }

    fun getBlockedPackages(context: Context): Set<String> {
        val prefs = getPrefs(context)
        val jsonString = prefs.getString(KEY_BLOCKED_PACKAGES, "[]") ?: "[]"
        val set = mutableSetOf<String>()
        try {
            val jsonArray = JSONArray(jsonString)
            for (i in 0 until jsonArray.length()) {
                set.add(jsonArray.getString(i))
            }
        } catch (_: Exception) {
        }
        return set
    }

    fun isPackageBlocked(context: Context, packageName: String): Boolean {
        if (!isSessionActive(context)) return false
        val blocked = getBlockedPackages(context)
        return blocked.contains(packageName)
    }

    fun getActiveSessionData(context: Context): Map<String, Any?>? {
        val prefs = getPrefs(context)
        if (!isSessionActive(context)) return null

        val blockedList = mutableListOf<String>()
        val jsonString = prefs.getString(KEY_BLOCKED_PACKAGES, "[]") ?: "[]"
        try {
            val jsonArray = JSONArray(jsonString)
            for (i in 0 until jsonArray.length()) {
                blockedList.add(jsonArray.getString(i))
            }
        } catch (_: Exception) {}

        return mapOf(
            "id" to prefs.getString(KEY_SESSION_ID, ""),
            "startTime" to prefs.getLong(KEY_START_TIME, 0L),
            "endTime" to prefs.getLong(KEY_END_TIME, 0L),
            "durationSeconds" to prefs.getLong(KEY_DURATION_SECONDS, 0L),
            "blockedPackages" to blockedList,
            "isStrict" to prefs.getBoolean(KEY_IS_STRICT, false),
            "label" to prefs.getString(KEY_SESSION_LABEL, ""),
            "remainingSeconds" to (getRemainingMillis(context) / 1000)
        )
    }
}
