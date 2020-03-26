import 'dart:async';

import 'package:flutter/services.dart';

class PdfText {
  static const MethodChannel _channel =
      const MethodChannel('pdf_text');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
