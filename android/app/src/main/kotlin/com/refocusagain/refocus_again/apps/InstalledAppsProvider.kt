package com.refocusagain.refocus_again.apps

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream

object InstalledAppsProvider {

    suspend fun getInstalledApps(context: Context): List<Map<String, String>> = withContext(Dispatchers.IO) {
        val pm = context.packageManager
        val mainIntent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }

        val resolveInfos = pm.queryIntentActivities(mainIntent, 0)
        val appList = mutableListOf<Map<String, String>>()
        val seenPackages = mutableSetOf<String>()

        for (resolveInfo in resolveInfos) {
            val packageName = resolveInfo.activityInfo.packageName
            if (packageName == context.packageName) continue
            if (seenPackages.contains(packageName)) continue

            seenPackages.add(packageName)

            val appName = try {
                resolveInfo.loadLabel(pm).toString()
            } catch (_: Exception) {
                packageName
            }

            val iconBase64 = try {
                val drawable = resolveInfo.loadIcon(pm)
                drawableToBase64(drawable)
            } catch (_: Exception) {
                ""
            }

            appList.add(
                mapOf(
                    "appName" to appName,
                    "packageName" to packageName,
                    "iconBase64" to iconBase64
                )
            )
        }

        appList.sortBy { it["appName"]?.lowercase() ?: "" }
        appList
    }

    private fun drawableToBase64(drawable: Drawable): String {
        val bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
            Bitmap.createScaledBitmap(drawable.bitmap, 96, 96, true)
        } else {
            val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 96
            val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 96
            val bmp = Bitmap.createBitmap(width.coerceAtMost(128), height.coerceAtMost(128), Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            Bitmap.createScaledBitmap(bmp, 96, 96, true)
        }

        val outputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 85, outputStream)
        return Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP)
    }
}
