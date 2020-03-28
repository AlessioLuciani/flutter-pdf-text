import Flutter
import UIKit
import PDFKit


public class SwiftPdfTextPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pdf_text", binaryMessenger: registrar.messenger())
    let instance = SwiftPdfTextPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
  if call.method == "getDocLength" {
          let path = call.arguments as! String
          self.getDocLength(result: result, path: path)
      }
    else if call.method == "getPlatformVersion" {
    result("iOS")
    } else {
              result(FlutterMethodNotImplemented)
            }

  }


  /**
              Gets the length of the PDF document in pages.
       */
      private func getDocLength(result: FlutterResult, path: String) {
          let doc = PDFDocument(url: URL(fileURLWithPath: path))
          if doc == nil {
              result(FlutterError(code: "INVALID_PATH",
                  message: "File path is invalid",
                  details: nil))
              return
          }
          let length = doc!.pageCount
          result(length)
      }
}
