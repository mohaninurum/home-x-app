package com.example.home_x_app.lockscreen

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class LockScreenReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        if (action == Intent.ACTION_SCREEN_OFF) {
            val lockIntent = Intent(context, LockScreenActivity::class.java)
            lockIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            context.startActivity(lockIntent)
        }
    }
}
