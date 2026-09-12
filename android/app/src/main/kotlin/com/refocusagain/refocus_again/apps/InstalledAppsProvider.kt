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
    private const val ICON_SIZE_PX = 96

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
        var bitmap: Bitmap? = null
        return try {
            if (drawable is BitmapDrawable && drawable.bitmap != null && !drawable.bitmap.isRecycled) {
                val original = drawable.bitmap
                // If it's a hardware bitmap, copy to software ARGB_8888
                val softwareBitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && original.config == Bitmap.Config.HARDWARE) {
                    original.copy(Bitmap.Config.ARGB_8888, false)
                } else {
                    original
                }

                if (softwareBitmap != null) {
                    bitmap = if (softwareBitmap.width == size && softwareBitmap.height == size) {
                        if (softwareBitmap == original) softwareBitmap.copy(Bitmap.Config.ARGB_8888, false) else softwareBitmap
                    } else {
                        Bitmap.createScaledBitmap(softwareBitmap, size, size, true)
                    }
                }
            }

            // For AdaptiveIconDrawable, VectorDrawable, LayerDrawable, or if bitmap is still null
            if (bitmap == null) {
                val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bmp)
                try {
                    drawable.setBounds(0, 0, size, size)
                    drawable.draw(canvas)
                    bitmap = bmp
                } catch (drawEx: Exception) {
                    Log.w(TAG, "Direct draw failed: ${drawEx.message}")
                    bmp.recycle()
                    bitmap = null
                }
            }

            if (bitmap == null) return null

            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            val bytes = stream.toByteArray()
            bytes
        } catch (e: Exception) {
            Log.w(TAG, "Failed to convert drawable to byte array: ${e.message}", e)
            null
        } finally {
            try {
                if (bitmap != null && bitmap != (drawable as? BitmapDrawable)?.bitmap) {
                    bitmap.recycle()
                }
            } catch (_: Exception) {}
        }
    }

    private fun getIconBytes(pm: PackageManager, packageName: String, drawableSupplier: (() -> Drawable?)? = null): ByteArray? {
        iconCache.get(packageName)?.let { return it }

        val bytes = try {
            val drawable = try {
                drawableSupplier?.invoke()
            } catch (_: Exception) {
                null
            } ?: try {
                pm.getApplicationIcon(packageName)
            } catch (_: Exception) {
                null
            }
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

            val resolveInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.queryIntentActivities(mainIntent, PackageManager.ResolveInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                pm.queryIntentActivities(mainIntent, 0)
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
                        try {
                            resolveInfo.activityInfo?.loadIcon(pm)
                        } catch (_: Exception) {
                            null
                        }
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
            Log.e(TAG, "Error in queryIntentActivities: ${e.message}", e)
        }

        // 2. Discover via Installed Applications (non-system user-installed apps)
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
                if (!isSystemApp) {
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
            Log.e(TAG, "Error in getInstalledApplications: ${e.message}", e)
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
