package com.mobilenext.milliways

import android.app.Application

class MilliwaysApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        MilliwaysRum.configureIfNeeded(this)
    }
}
