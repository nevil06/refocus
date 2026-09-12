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
import android.util.Log
import android.util.LruCache
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream

object InstalledAppsProvider {
    private const val TAG = "InstalledAppsProvider"
    private const val ICON_SIZE_PX = 128

    // Memory cache for icon byte arrays (stores up to 300 app icons)
    private val iconCache = object : LruCache<String, ByteArray>(300) {}

    // Top distracting apps catalog
    private val POPULAR_APPS = listOf(
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
        Pair("Amazon Prime Video", "com.amazon.avod.thirdpartyclient"),
        Pair("Twitch", "tv.twitch.android.app"),
        Pair("Roblox", "com.roblox.client"),
        Pair("Candy Crush", "com.king.candycrushsaga"),
        Pair("Subway Surfers", "com.kiloo.subwaysurf"),
        Pair("Brawl Stars", "com.supercell.brawlstars"),
        Pair("Clash Royale", "com.supercell.clashroyale"),
        Pair("PUBG Mobile", "com.tencent.ig")
    )

    private fun drawableToByteArray(drawable: Drawable?, size: Int = ICON_SIZE_PX): ByteArray? {
        if (drawable == null) return null
        return try {
            val bitmap = when {
                drawable is BitmapDrawable && drawable.bitmap != null -> {
                    val original = drawable.bitmap
                    if (original.width <= size && original.height <= size && !original.isRecycled) {
                        original
                    } else {
                        Bitmap.createScaledBitmap(original, size, size, true)
                    }
                }
                else -> {
                    val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else size
                    val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else size
                    val targetW = if (width > size) size else width
                    val targetH = if (height > size) size else height
                    val bitmap = Bitmap.createBitmap(targetW, targetH, Bitmap.Config.ARGB_8888)
                    val canvas = Canvas(bitmap)
                    drawable.setBounds(0, 0, canvas.width, canvas.height)
                    drawable.draw(canvas)
                    bitmap
                }
            }

            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 90, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            Log.w(TAG, "Failed to convert drawable to byte array: ${e.message}")
            null
        }
    }

    private fun getIconBytes(pm: PackageManager, packageName: String, drawableSupplier: (() -> Drawable?)? = null): ByteArray? {
        iconCache.get(packageName)?.let { return it }

        val bytes = try {
            val drawable = drawableSupplier?.invoke() ?: pm.getApplicationIcon(packageName)
            drawableToByteArray(drawable)
        } catch (_: Exception) {
            null
        }

        if (bytes != null) {
            iconCache.put(packageName, bytes)
        }
        return bytes
    }

    suspend fun getInstalledApps(context: Context): List<Map<String, Any?>> = withContext(Dispatchers.IO) {
        val pm = context.packageManager
        val appList = mutableListOf<Map<String, Any?>>()
        val seenPackages = mutableSetOf<String>()

        // Exclude Refocus itself
        val ownPackageName = context.packageName
        seenPackages.add(ownPackageName)

        // 1. Discover via Launcher Intent Activities
        try {
            val mainIntent = Intent(Intent.ACTION_MAIN, null).apply {
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
                val pkg = resolveInfo.activityInfo?.packageName ?: continue
                if (seenPackages.contains(pkg)) continue
                seenPackages.add(pkg)

                val name = try {
                    resolveInfo.loadLabel(pm).toString()
                } catch (_: Exception) {
                    pkg
                }

                val iconBytes = getIconBytes(pm, pkg) {
                    try {
                        resolveInfo.loadIcon(pm)
                    } catch (_: Exception) {
                        null
                    }
                }

                appList.add(
                    mapOf(
                        "appName" to name,
                        "packageName" to pkg,
                        "iconBytes" to iconBytes,
                        "iconBase64" to ""
                    )
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error in queryIntentActivities: ${e.message}")
        }

        // 2. Discover via Installed Applications
        try {
            val installedApps = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getInstalledApplications(PackageManager.ApplicationInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                pm.getInstalledApplications(0)
            }

            for (appInfo in installedApps) {
                val pkg = appInfo.packageName ?: continue
                if (seenPackages.contains(pkg)) continue

                val isSystemApp = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
                val hasLaunchIntent = pm.getLaunchIntentForPackage(pkg) != null

                if (hasLaunchIntent || !isSystemApp) {
                    seenPackages.add(pkg)

                    val name = try {
                        pm.getApplicationLabel(appInfo).toString()
                    } catch (_: Exception) {
                        pkg
                    }

                    val iconBytes = getIconBytes(pm, pkg) {
                        try {
                            pm.getApplicationIcon(appInfo)
                        } catch (_: Exception) {
                            null
                        }
                    }

                    appList.add(
                        mapOf(
                            "appName" to name,
                            "packageName" to pkg,
                            "iconBytes" to iconBytes,
                            "iconBase64" to ""
                        )
                    )
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error in getInstalledApplications: ${e.message}")
        }

        // 3. Fallback: Always ensure top popular distracting apps are in the list
        for ((name, pkg) in POPULAR_APPS) {
            if (!seenPackages.contains(pkg)) {
                seenPackages.add(pkg)
                val iconBytes = getIconBytes(pm, pkg)

                appList.add(
                    mapOf(
                        "appName" to name,
                        "packageName" to pkg,
                        "iconBytes" to iconBytes,
                        "iconBase64" to ""
                    )
                )
            }
        }

        appList.sortBy { (it["appName"] as? String)?.lowercase() ?: "" }
        appList
    }
}
