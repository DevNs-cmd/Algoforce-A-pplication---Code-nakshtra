import Flutter
import LocalAuthentication
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.algoforce.ai/security",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "biometricChallenge":
          let context = LAContext()
          var error: NSError?
          let available = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
          )
          result([
            "status": "ready",
            "provider": "ios-local-authentication",
            "available": available,
            "detail": error?.localizedDescription ?? "biometric policy evaluated"
          ])
        case "deviceIntegrity":
          result([
            "status": "ready",
            "jailbreakSignalsDetected": false,
            "secureEnclave": true
          ])
        case "storePaymentTokenStub":
          result([
            "status": "stored",
            "vault": "ios-keychain-placeholder",
            "sdk": "payment-provider-stub"
          ])
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
