package com.manuelacbl.buzz_app

import com.manuelacbl.buzz_app.buzzers.BuzzDeviceHandler
import com.manuelacbl.buzz_app.cast.CastHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine.plugins.add(BuzzDeviceHandler())
        flutterEngine.plugins.add(CastHandler(context = context))
    }
}

