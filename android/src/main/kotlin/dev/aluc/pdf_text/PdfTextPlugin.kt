package dev.aluc.pdf_text

import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

import java.io.File


import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.PDPage
import com.tom_roush.pdfbox.text.PDFTextStripper
import kotlin.concurrent.thread

/** PdfTextPlugin */
public class PdfTextPlugin: FlutterPlugin, MethodCallHandler {

  /**
   * PDF document cached from the previous use.
   */
  private var cachedDoc: PDDocument? = null
  private var cachedDocPath: String? = null

  /**
   * PDF text stripper.
   */
  private var pdfTextStripper = PDFTextStripper()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "pdf_text")
    channel.setMethodCallHandler(PdfTextPlugin());
  }



  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "pdf_text")
      channel.setMethodCallHandler(PdfTextPlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    thread (start = true) {
      when (call.method) {
          "initDoc" -> {
            val args = call.arguments as Map<String, Any>
            val path = args["path"] as String
            val password = args["password"] as String
            initDoc(result, path, password)
          }
          "getDocPageText" -> {
            val args = call.arguments as Map<String, Any>
            val path = args["path"] as String
            val pageNumber = args["number"] as Int
            getDocPageText(result, path, pageNumber)
          }
          "getDocText" -> {
            val args = call.arguments as Map<String, Any>
            val path = args["path"] as String
            val missingPagesNumbers = args["missingPagesNumbers"] as List<Int>
            getDocText(result, path, missingPagesNumbers)
          }
          else -> {
            Handler(Looper.getMainLooper()).post {
              result.notImplemented()
            }

          }
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }

  /**
    Initializes the PDF document and returns some information into the channel.
   */
  private fun initDoc(result: Result, path: String, password: String) {
    val doc = getDoc(result, path, password) ?: return
    // Getting the length of the PDF document in pages.
    val length = doc.numberOfPages

    val info = doc.documentInformation

    var creationDate: String? = null
    if (info.creationDate != null) {
      creationDate = info.creationDate.time.toString()
    }
    var modificationDate: String? = null
    if (info.modificationDate != null) {
      modificationDate = info.modificationDate.time.toString()
    }
    val data = hashMapOf<String, Any>(
            "length" to length,
            "info" to hashMapOf("author" to info.author,
                    "creationDate" to creationDate,
                    "modificationDate" to modificationDate,
                    "creator" to info.creator, "producer" to info.producer,
                    "keywords" to splitKeywords(info.keywords),
                    "title" to info.title, "subject" to info.subject
            )
    )

    Handler(Looper.getMainLooper()).post {
      result.success(data)
    }
  }

  /**
   * Splits a string of keywords into a list of strings.
   */
  private fun splitKeywords(keywordsString: String?): List<String>? {
    if (keywordsString == null) {
      return null
    }
    var keywords = keywordsString.split(",").toMutableList()
    for (i in keywords.indices) {
      var keyword = keywords[i]
      keyword = keyword.dropWhile { it == ' ' }
      keyword = keyword.dropLastWhile { it == ' ' }
      keywords[i] = keyword
    }
    return keywords
  }

  /**
    Gets the text  of a document page, given its number.
   */
  private fun getDocPageText(result: Result, path: String, pageNumber: Int) {
    val doc = getDoc(result, path) ?: return
    pdfTextStripper.startPage = pageNumber
    pdfTextStripper.endPage = pageNumber
    val text = pdfTextStripper.getText(doc)
    Handler(Looper.getMainLooper()).post {
      result.success(text)
    }
  }

  /**
  Gets the text of the entire document.
  In order to improve the performance, it only retrieves the pages that are currently missing.
   */
  private fun getDocText(result: Result, path: String, missingPagesNumbers: List<Int>) {
    val doc = getDoc(result, path) ?: return
    var missingPagesTexts = arrayListOf<String>()
    missingPagesNumbers.forEach {
      pdfTextStripper.startPage = it
      pdfTextStripper.endPage = it
      missingPagesTexts.add(pdfTextStripper.getText(doc))
    }
    Handler(Looper.getMainLooper()).post {
      result.success(missingPagesTexts)
    }
  }

  /**
  Gets a PDF document, given its path.
   */
  private fun getDoc(result: Result, path: String, password: String = ""): PDDocument? {
    // Checking for cached document
    if (cachedDoc != null && cachedDocPath == path) {
      return cachedDoc
    }
    return try {
      val doc = PDDocument.load(File(path), password)
      cachedDoc = doc
      cachedDocPath = path
      initTextStripperEngine(doc)
      doc
    } catch (e: Exception) {
      Handler(Looper.getMainLooper()).post {
        result.error("INVALID_PATH",
                "File path or password (in case of encrypted document) is invalid",
                null)
      }
      null
    }
  }

  /**
   * Initializes the text stripper engine. This can take some time.
   */
  private fun initTextStripperEngine(doc: PDDocument) {
    pdfTextStripper.startPage = 1
    pdfTextStripper.endPage = 1
    pdfTextStripper.getText(doc)
  }
}
