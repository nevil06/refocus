package com.refocusagain.refocus_again

import com.refocusagain.refocus_again.bridge.RefocusNativeBridge
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        RefocusNativeBridge.registerWith(
            flutterEngine.dartExecutor.binaryMessenger,
            context,
            this
        )
    }
}
