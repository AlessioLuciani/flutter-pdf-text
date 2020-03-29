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
    let args = call.arguments as! NSDictionary
          let path = args["path"] as! String
          getDocLength(result: result, path: path)
  } else if call.method == "getDocPageText" {
        let args = call.arguments as! NSDictionary
        let path = args["path"] as! String
        let pageNumber = args["number"] as! Int
        getDocPageText(result: result, path: path, pageNumber: pageNumber)
  }
     else if call.method == "getDocText" {
        let args = call.arguments as! NSDictionary
        let path = args["path"] as! String
        let missingPagesNumbers = args["missingPagesNumbers"] as! [Int]
        getDocText(result: result, path: path, missingPagesNumbers: missingPagesNumbers)
  }
    else {
              result(FlutterMethodNotImplemented)
            }

  }


  /**
              Gets the length of the PDF document in pages.
       */
      private func getDocLength(result: FlutterResult, path: String) {
        let doc = getDoc(result: result, path: path)
        if doc == nil {
            return
        }
          let length = doc!.pageCount
          result(length)
      }
    
    /**
            Gets the text  of a document page, given its number..
     */
    private func getDocPageText(result: FlutterResult, path: String, pageNumber: Int) {
      let doc = getDoc(result: result, path: path)
        if doc == nil {
            return
        }
        let text = doc!.page(at: pageNumber)!.string
        result(text)
    }
    
    /**
            Gets the text of the entire document.
            In order to improve the performance, it only retrieves the pages that are currently missing.
     */
    private func getDocText(result: FlutterResult, path: String, missingPagesNumbers: [Int]) {
      let doc = getDoc(result: result, path: path)
        if doc == nil {
            return
        }
        var missingPagesTexts = [String]()
        for pageNumber in missingPagesNumbers {
            missingPagesTexts.append(doc!.page(at: pageNumber)!.string!)
        }
        result(missingPagesTexts)
    }
    
    /**
           Gets a PDF document, given its path.
    */
    private func getDoc(result: FlutterResult, path: String) -> PDFDocument? {
        let doc = PDFDocument(url: URL(fileURLWithPath: path))
        if doc == nil {
            result(FlutterError(code: "INVALID_PATH",
                message: "File path is invalid",
                details: nil))
        }
        return doc
    }
}
