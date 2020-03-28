import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';



/// Class representing a PDF document.
class PDFDoc {

  static const MethodChannel _channel =
  const MethodChannel('pdf_text');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> get text async {
    final String text = await _channel.invokeMethod('getText');
    return text;
  }


  File _file;
  List<_PDFPage> _pages;

  /// Creates a PDFDoc object with a File instance.
  static Future<PDFDoc> fromFile(File file) async {
    var doc = PDFDoc();
    doc._file = file;
    int length;
    try {
      length = await _channel.invokeMethod('getDocLength', file.path);
    } on Exception catch (e) {
      return Future.error(e);
    }
    doc._pages = List();
    for (int i = 0; i < length; i++) {
      doc._pages.add(_PDFPage());
    }
    return doc;
  }

  /// Creates a PDFDoc object with a file path.
  static Future<PDFDoc> fromPath(String path) async {
    return await fromFile(File(path));
  }


  List<_PDFPage> get pages => _pages;

  int get length => _pages.length;




}


/// Class representing a PDF document page.
class _PDFPage {
  String _text;

  String get text => _text;
}

