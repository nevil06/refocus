package com.refocusagain.refocus_again.apps

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.util.Base64
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream

object InstalledAppsProvider {

    // Common distracting apps fallback list to guarantee user always has popular options ready
    private val POPULAR_DISTRACTING_APPS = listOf(
        Pair("Instagram", "com.instagram.android"),
        Pair("YouTube", "com.google.android.youtube"),
        Pair("Snapchat", "com.snapchat.android"),
        Pair("Reddit", "com.reddit.frontpage"),
        Pair("Chrome", "com.android.chrome"),
        Pair("TikTok", "com.zhiliaoapp.musically"),
        Pair("Facebook", "com.facebook.katana"),
        Pair("X (Twitter)", "com.twitter.android"),
        Pair("Netflix", "com.netflix.mediaclient"),
        Pair("Discord", "com.discord"),
        Pair("Pinterest", "com.pinterest"),
        Pair("WhatsApp", "com.whatsapp"),
        Pair("Telegram", "org.telegram.messenger"),
        Pair("Spotify", "com.spotify.music"),
        Pair("Prime Video", "com.amazon.avod.thirdpartyclient")
    )

    suspend fun getInstalledApps(context: Context): List<Map<String, String>> = withContext(Dispatchers.IO) {
        val pm = context.packageManager
        val appList = mutableListOf<Map<String, String>>()
        val seenPackages = mutableSetOf<String>()

        // 1. Primary Method: Query Launcher Intent Activities
        try {
            val mainIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_LAUNCHER)
            }

            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PackageManager.MATCH_ALL
            } else {
                0
            }

            val resolveInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.queryIntentActivities(mainIntent, PackageManager.ResolveInfoFlags.of(flags.toLong()))
            } else {
                @Suppress("DEPRECATION")
                pm.queryIntentActivities(mainIntent, flags)
            }

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
        } catch (_: Exception) {}

        // 2. Secondary Method: Query Installed Applications if list is small/empty
        try {
            val apps = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getInstalledApplications(PackageManager.ApplicationInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                pm.getInstalledApplications(0)
            }

            for (appInfo in apps) {
                val packageName = appInfo.packageName
                if (packageName == context.packageName) continue
                if (seenPackages.contains(packageName)) continue

                // Check if it's a launchable app or non-system app
                val isNonSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0
                val launchIntent = pm.getLaunchIntentForPackage(packageName)

                if (launchIntent != null || isNonSystem) {
                    seenPackages.add(packageName)

                    val appName = try {
                        pm.getApplicationLabel(appInfo).toString()
                    } catch (_: Exception) {
                        packageName
                    }

                    val iconBase64 = try {
                        val drawable = pm.getApplicationIcon(appInfo)
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
            }
        } catch (_: Exception) {}

        // 3. Fallback: Add popular distracting apps if not already present
        for ((name, pkg) in POPULAR_DISTRACTING_APPS) {
            if (!seenPackages.contains(pkg)) {
                // Check if installed on device
                val isInstalled = try {
                    pm.getPackageInfo(pkg, 0)
                    true
                } catch (_: Exception) {
                    false
                }

                // If installed or if total discovered apps list is empty, include it
                if (isInstalled || appList.isEmpty()) {
                    seenPackages.add(pkg)
                    val iconBase64 = try {
                        val icon = pm.getApplicationIcon(pkg)
                        drawableToBase64(icon)
                    } catch (_: Exception) {
                        ""
                    }

                    appList.add(
                        mapOf(
                            "appName" to name,
                            "packageName" to pkg,
                            "iconBase64" to iconBase64
                        )
                    )
                }
            }
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
