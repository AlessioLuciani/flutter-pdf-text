import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pdf_text/pdf_text.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  PDFDoc _pdfDoc;
  String _text = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await PDFDoc.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PDF Text Example'),
        ),
        body: Column(
          children: <Widget>[
            FlatButton(
              child: Text("Pick PDF document",
                style: TextStyle(color: Colors.white),),
              color: Colors.blueAccent,
              onPressed: _pickPDFText,
              padding: EdgeInsets.all(5),
            ),
            FlatButton(
              child: Text("Read random page",
                style: TextStyle(color: Colors.white),),
              color: Colors.blueAccent,
              onPressed: _readRandomPage,
              padding: EdgeInsets.all(5),
            ),
            FlatButton(
              child: Text("Read whole document",
                style: TextStyle(color: Colors.white),),
              color: Colors.blueAccent,
              onPressed: _readWholeDoc,
              padding: EdgeInsets.all(5),
            ),

            Padding(
              child: Text(_pdfDoc == null ? "Pick a new PDF document..."
                  : "PDF document picked, ${_pdfDoc.length} pages\n"),
              padding: EdgeInsets.all(15),
            ),
            Padding(
              child: Text(_text == "" ? "" : "Text:"),
              padding: EdgeInsets.all(15),
            ),

            ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Text(_text)
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Picks a new PDF document from the device
  Future _pickPDFText() async {
    File file = await FilePicker.getFile();
    _pdfDoc = await PDFDoc.fromFile(file);
    setState(() {});
  }

  /// Reads a random page of the document
  Future _readRandomPage() async {
    if (_pdfDoc == null) {
      return;
    }


    setState(() {});
  }

  /// Reads the whole document
  Future _readWholeDoc() async {
    if (_pdfDoc == null) {
      return;
    }

    setState(() {});
  }
}
