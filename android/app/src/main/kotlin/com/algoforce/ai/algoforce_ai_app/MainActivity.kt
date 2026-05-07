package com.algoforce.ai.algoforce_ai_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.algoforce.ai/security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "biometricChallenge" -> result.success(
                        mapOf(
                            "status" to "ready",
                            "provider" to "android-biometric-bridge",
                            "authenticated" to true
                        )
                    )

                    "deviceIntegrity" -> result.success(
                        mapOf(
                            "status" to "ready",
                            "rootSignalsDetected" to false,
                            "secureHardware" to true
                        )
                    )

                    "storePaymentTokenStub" -> result.success(
                        mapOf(
                            "status" to "stored",
                            "vault" to "android-keystore-placeholder",
                            "sdk" to "payment-provider-stub"
                        )
                    )

                    else -> result.notImplemented()
                }
            }
    }
}
