import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

const MethodChannel _CHANNEL = const MethodChannel('pdf_text');
const String _TEMP_DIR_NAME = "/.flutter_pdf_text/";

/// Class representing a PDF document.
/// In order to create a new [PDFDoc] instance, one of these two static methods has
///  to be used: [PDFDoc.fromFile], [PDFDoc.fromPath].
class PDFDoc {

  File _file;
  List<PDFPage> _pages;

  PDFDoc._internal();

  /// Creates a [PDFDoc] object with a [File] instance.
  /// Optionally, takes a password for encrypted PDF documents.
  static Future<PDFDoc> fromFile(File file, {String password = ""}) async {
    var doc = PDFDoc._internal();
    doc._file = file;
    int length;
    try {
      length = await _CHANNEL.invokeMethod('getDocLength', 
          {"path": file.path, "password": password});
    } on Exception catch (e) {
      return Future.error(e);
    }
    doc._pages = List();
    for (int i = 0; i < length; i++) {
      doc._pages.add(PDFPage._fromDoc(doc, i));
    }
    return doc;
  }

  /// Creates a [PDFDoc] object with a file path.
  /// Optionally, takes a password for encrypted PDF documents.
  static Future<PDFDoc> fromPath(String path, {String password = ""}) async {
    return await fromFile(File(path), password: password);
  }

  /// Creates a [PDFDoc] object with a URL.
  /// Optionally, takes a password for encrypted PDF documents.
  /// It downloads the PDF file located in the given URL and saves it
  /// in the app's temporary directory.
  static Future<PDFDoc> fromURL(String url, {String password = ""}) async {
    File file;
    try {
      String tempDirPath = (await getTemporaryDirectory()).path;
      String filePath = tempDirPath + _TEMP_DIR_NAME 
        + url.split("/").last.split(".").first + ".pdf";
      file = File(filePath);
      file.createSync(recursive: true);
      file.writeAsBytesSync((await http.get(url)).bodyBytes);
    } on Exception catch (e) {
      return Future.error(e);
    }
    return await fromFile(file, password: password);
  }

  /// Gets the page of the document at the given page number.
  PDFPage pageAt(int pageNumber) => _pages[pageNumber - 1];


  /// Gets the pages of this document.
  /// The pages indexes start at 0, but the first page has number 1.
  /// Therefore, if you need to access the 5th page, you will do:
  /// var page = doc.pages[4]
  /// print(page.number) -> 5
  List<PDFPage> get pages => _pages;

  /// Gets the number of pages of this document.
  int get length => _pages.length;

  /// Gets the entire text content of the document.
  Future<String> get text async {
    // Collecting missing pages
    List<int> missingPagesNumbers = List();
    _pages.forEach((page) {
      if (page._text == null) {
        missingPagesNumbers.add(page.number);
      }
    });
    List<String> missingPagesTexts;
    try {
      missingPagesTexts = List<String>.from(await _CHANNEL.invokeMethod('getDocText', {"path": _file.path,
        "missingPagesNumbers": missingPagesNumbers}));
    } on Exception catch (e) {
      return Future.error(e);
    }
    // Populating missing pages
    for (var i = 0; i < missingPagesNumbers.length; i++) {
      pageAt(missingPagesNumbers[i])._text = missingPagesTexts[i];
    }
    String text = "";
    _pages.forEach((page)
        => text += "${page._text}\n"
    );
    if(text.replaceAll(RegExp(r"\s+\b|\n"),"").length<=0){
     // true, means text have only whiteSpaces and new lines,basically nothing will show on user screen
    // means pdf contain images that can't convert into text
    // if you want you can throw exection but i'am just sending a massage that coder show  to users
      return "Pdf contain images that can't convert to Text...try another Pdf"
      
    }
    return text;
  }

  /// Deletes the file related to this [PDFDoc].
  /// Throws an exception if the [FileSystemEntity] cannot be deleted.
  void deleteFile() {
    if (_file.existsSync()) {
      _file.deleteSync();
    }
  }

  /// Deletes all the files of the documents that have been imported
  /// from outside the local file system (e.g. using [fromURL]).
  static Future deleteAllExternalFiles() async {
    try {
      String tempDirPath = (await getTemporaryDirectory()).path;
      String dirPath = tempDirPath + _TEMP_DIR_NAME;
      Directory dir = Directory(dirPath);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    } catch (e) {
      return Future.error(e);
    }
  }

}

/// Class representing a PDF document page.
/// It needs not to be directly instantiated, instances will be automatically
/// created by the [PDFDoc] class.
class PDFPage {

  PDFDoc _parentDoc;
  int _number;
  String _text;

  PDFPage._fromDoc(PDFDoc parentDoc, int number) {
    _parentDoc = parentDoc;
    _number = number;
  }

  /// Gets the text of this page.
  /// The text retrieval is lazy. So the text of a page is only loaded when
  /// it is requested for the first time.
  Future<String> get text async {
    // Loading the text
    if (_text == null) {
      try {
        _text = await _CHANNEL.invokeMethod('getDocPageText', {"path": _parentDoc._file.path,
            "number": number});
      } on Exception catch (e) {
        return Future.error(e);
      }
    }
    return _text;
  }

  /// Gets the page number.
  int get number => _number + 1;
}

