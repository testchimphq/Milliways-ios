package com.mobilenext.milliways

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mobilenext.milliways.ui.MilliwaysRoot
import io.testchimp.rum.TestChimpRum

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        TestChimpRum.handleAutomationIntent(intent)
        enableEdgeToEdge()
        setContent {
            val vm: AppViewModel = viewModel()
            MilliwaysRoot(vm)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        TestChimpRum.handleAutomationIntent(intent)
    }
}
