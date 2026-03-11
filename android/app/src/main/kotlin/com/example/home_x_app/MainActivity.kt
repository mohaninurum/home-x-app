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

        val bitmap = if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {

            val bmp = Bitmap.createBitmap(
                drawable.intrinsicWidth.coerceAtLeast(1),
                drawable.intrinsicHeight.coerceAtLeast(1),
                Bitmap.Config.ARGB_8888
            )

            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)

            bmp
        }

        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)

        return stream.toByteArray()
    }
}