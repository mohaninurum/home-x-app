package com.example.home_x_app.lockscreen

import android.app.Service
import android.content.Intent
import android.content.IntentFilter
import android.os.IBinder

class LockScreenService : Service() {
    private lateinit var receiver: LockScreenReceiver

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        receiver = LockScreenReceiver()
        val filter = IntentFilter(Intent.ACTION_SCREEN_OFF)
        registerReceiver(receiver, filter)
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(receiver)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }
}
