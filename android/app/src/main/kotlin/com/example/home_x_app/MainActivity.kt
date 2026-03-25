package com.example.home_x_app

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import java.io.ByteArrayOutputStream
import androidx.annotation.NonNull
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity: FlutterFragmentActivity() {

    private val CHANNEL = "com.example.homexapp/launcher"
    private val scope = CoroutineScope(Dispatchers.Main)

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                when (call.method) {

                    "getApps" -> {
                        // Run on IO thread — loading icons is very slow on main thread
                        scope.launch {
                            try {
                                val apps = withContext(Dispatchers.IO) { getInstalledApps() }
                                result.success(apps)
                            } catch (e: Exception) {
                                result.error("GET_APPS_ERROR", e.message, null)
                            }
                        }
                    }

                    "launchApp" -> {
                        val packageName = call.argument<String>("packageName")

                        if (packageName != null) {
                            try {
                                val intent = packageManager.getLaunchIntentForPackage(packageName)

                                if (intent != null) {
                                    startActivity(intent)
                                    result.success(true)
                                } else {
                                    result.success(false)
                                }

                            } catch (e: Exception) {
                                result.error("LAUNCH_ERROR", e.message, null)
                            }
                        } else {
                            result.error("INVALID_PACKAGE", "Package name is null", null)
                        }
                    }

                    "openAppInfo" -> {
                        val packageName = call.argument<String>("packageName")
                        if (packageName != null) {
                            try {
                                val intent = Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                                intent.data = android.net.Uri.parse("package:$packageName")
                                startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("OPEN_APP_INFO_ERROR", e.message, null)
                            }
                        } else {
                            result.error("INVALID_PACKAGE", "Package name is null", null)
                        }
                    }

                    "startLockService" -> {
                        val serviceIntent = Intent(
                            this,
                            com.example.home_x_app.lockscreen.LockScreenService::class.java
                        )

                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                            startForegroundService(serviceIntent)
                        } else {
                            startService(serviceIntent)
                        }

                        result.success(true)
                    }

                    "openDefaultLauncherSettings" -> {
                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                            val roleManager = getSystemService(android.app.role.RoleManager::class.java)
                            if (roleManager != null && roleManager.isRoleAvailable(android.app.role.RoleManager.ROLE_HOME)) {
                                if (!roleManager.isRoleHeld(android.app.role.RoleManager.ROLE_HOME)) {
                                    val intent = roleManager.createRequestRoleIntent(android.app.role.RoleManager.ROLE_HOME)
                                    startActivityForResult(intent, 1001)
                                }
                                result.success(true)
                                return@setMethodCallHandler
                            }
                        }

                        try {
                            val intent = Intent(android.provider.Settings.ACTION_HOME_SETTINGS)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            val intent = Intent(android.provider.Settings.ACTION_SETTINGS)
                            startActivity(intent)
                            result.success(false)
                        }
                    }

                    "uninstallApp" -> {
                        val packageName = call.argument<String>("packageName")
                        if (packageName != null) {
                            try {
                                val intent = Intent(Intent.ACTION_DELETE)
                                intent.data = android.net.Uri.parse("package:$packageName")
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("UNINSTALL_ERROR", e.message, null)
                            }
                        } else {
                            result.error("INVALID_PACKAGE", "Package name is null", null)
                        }
                    }

                    "openWifiSettings" -> {
                        try {
                            val intent = Intent(android.provider.Settings.ACTION_WIFI_SETTINGS)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("WIFI_ERROR", e.message, null)
                        }
                    }

                    "openBluetoothSettings" -> {
                        try {
                            val intent = Intent(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("BLUETOOTH_ERROR", e.message, null)
                        }
                    }

                    "openMobileDataSettings" -> {
                        try {
                            val intent = Intent(android.provider.Settings.ACTION_DATA_ROAMING_SETTINGS)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            try {
                                val intent2 = Intent(android.provider.Settings.ACTION_WIRELESS_SETTINGS)
                                startActivity(intent2)
                                result.success(true)
                            } catch (e2: Exception) {
                                result.error("DATA_ERROR", e2.message, null)
                            }
                        }
                    }

                    "openNotificationPanel" -> {
                        try {
                            val statusBarService = getSystemService("statusbar")
                            val statusBarManager = Class.forName("android.app.StatusBarManager")
                            val expandMethod = statusBarManager.getMethod("expandNotificationsPanel")
                            expandMethod.invoke(statusBarService)
                            result.success(true)
                        } catch (e: Exception) {
                            try {
                                // Fallback for various Android versions
                                val statusBarService = getSystemService("statusbar")
                                val statusBarManager = Class.forName("android.app.StatusBarManager")
                                val expandMethod = statusBarManager.getMethod("expand")
                                expandMethod.invoke(statusBarService)
                                result.success(true)
                            } catch (e2: Exception) {
                                result.error("OPEN_NOTIFICATION_ERROR", e2.message, null)
                            }
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun getInstalledApps(): List<Map<String, Any>> {

        val intent = Intent(Intent.ACTION_MAIN, null)
        intent.addCategory(Intent.CATEGORY_LAUNCHER)

        val allApps = packageManager.queryIntentActivities(intent, 0)
        val appList = mutableListOf<Map<String, Any>>()

        for (resolveInfo in allApps) {

            val pkgName = resolveInfo.activityInfo.packageName

            // Skip our launcher
            if (pkgName == packageName) continue

            val label = resolveInfo.loadLabel(packageManager).toString()
            val icon = resolveInfo.loadIcon(packageManager)
            val iconBytes = drawableToByteArray(icon)

            val appData = mapOf(
                "packageName" to pkgName,
                "label" to label,
                "icon" to iconBytes
            )

            appList.add(appData)
        }

        return appList.sortedBy { it["label"].toString().lowercase() }
    }

    private fun drawableToByteArray(drawable: Drawable): ByteArray {
        val maxWidth = 144
        val maxHeight = 144

        val width = drawable.intrinsicWidth.coerceAtMost(maxWidth).coerceAtLeast(1)
        val height = drawable.intrinsicHeight.coerceAtMost(maxHeight).coerceAtLeast(1)

        val bitmap = if (drawable is BitmapDrawable && drawable.bitmap.width <= maxWidth && drawable.bitmap.height <= maxHeight) {
            drawable.bitmap
        } else {
            val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bmp
        }

        val stream = ByteArrayOutputStream()
        // Use WEBP if available (API 30+), else WEBP
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            bitmap.compress(Bitmap.CompressFormat.WEBP_LOSSY, 80, stream)
        } else {
            @Suppress("DEPRECATION")
            bitmap.compress(Bitmap.CompressFormat.WEBP, 80, stream)
        }

        return stream.toByteArray()
    }
}