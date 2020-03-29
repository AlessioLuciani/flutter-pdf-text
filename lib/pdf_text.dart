import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';


const MethodChannel channel = const MethodChannel('pdf_text');

/// Class representing a PDF document.
class PDFDoc {


  File _file;
  List<_PDFPage> _pages;

  /// Creates a PDFDoc object with a File instance.
  static Future<PDFDoc> fromFile(File file) async {
    var doc = PDFDoc();
    doc._file = file;
    int length;
    try {
      length = await channel.invokeMethod('getDocLength', {"path": file.path});
    } on Exception catch (e) {
      return Future.error(e);
    }
    doc._pages = List();
    for (int i = 0; i < length; i++) {
      doc._pages.add(_PDFPage(doc, i));
    }
    return doc;
  }

  /// Creates a PDFDoc object with a file path.
  static Future<PDFDoc> fromPath(String path) async {
    return await fromFile(File(path));
  }


  /// Gets the page of the document at the given page number.
  _PDFPage pageAt(int pageNumber) => _pages[pageNumber - 1];


  /// Gets the pages of this document.
  /// The pages indexes start at 0, but the first page has number 1.
  /// Therefore, if you need to access the 5th page, you will do:
  /// var page = doc.pages[4]
  /// print(page.number) -> 5
  List<_PDFPage> get pages => _pages;

  /// Gets the number of pages of this document.
  int get length => _pages.length;

  /// Gets the entire text content of the document.
  Future<String> get text async {
    // Collecting missing pages
    List<int> missingPagesNumbers = List();
    for (var page in _pages) {
      if (page.text == null) {
        missingPagesNumbers.add(page.number);
      }
    }
    List<String> missingPagesTexts;
    try {
      missingPagesTexts = List<String>.from(await channel.invokeMethod('getDocText', {"path": _file.path,
        "missingPagesNumbers": missingPagesNumbers}));
    } on Exception catch (e) {
      return Future.error(e);
    }
    // Populating missing pages
    for (var i = 0; i < missingPagesNumbers.length; i++) {
      pageAt(missingPagesNumbers[i])._text = missingPagesTexts[i];
    }
    String text = "";
    for (var page in _pages) {
      text += "${page._text}\n";
    }
    return text;
  }


}


/// Class representing a PDF document page.
class _PDFPage {

  PDFDoc _parentDoc;
  int _number;
  String _text;

  _PDFPage(PDFDoc parentDoc, int number) {
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
        _text = await channel.invokeMethod('getDocPageText', {"path": _parentDoc._file.path,
            "number": _number});
      } on Exception catch (e) {
        return Future.error(e);
      }
    }
    return _text;
  }

  /// Gets the page number.
  int get number => _number + 1;
}

