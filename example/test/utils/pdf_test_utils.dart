import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optional/optional.dart';
import 'package:path/path.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';

import 'test_doc_info.dart';

class PdfTestUtils {
  final String testDirectoryPath;

  PdfTestUtils(this.testDirectoryPath);

  /// Creates a basic, single or multipage pdf document with optional info and
  /// saves it to a File that is subsequently returned wrapped in a Future
  Future<File> createPdfFile(List<List<String>> pages,
      {TestDocInfo? info}) async {
    final pdf = Optional.ofNullable(info)
        .map((i) => pw.Document(
            title: i.title,
            author: i.author,
            creator: i.creator,
            subject: i.subject,
            keywords: i.keywords))
        .orElse(pw.Document());

    final pdfPages = pages
        .map((page) => pw.MultiPage(

            /// a3 format so long lines will hopefully not be broken
            pageFormat: PdfPageFormat.a3,
            build: (pw.Context context) =>
                page.map((line) => pw.Paragraph(text: line)).toList()))
        .toList();
    pdfPages.forEach((page) {
      pdf.addPage(page);
    });

    String testFile = join(testDirectoryPath, "${Uuid().v1()}.pdf");
    final file = File(testFile);

    await file.writeAsBytes(await pdf.save());
    return file;
  }
}

bool get isIos => defaultTargetPlatform == TargetPlatform.iOS;

/// A trick to wait till all awaits defined inside tester function get their
/// results so the checks are finished. (avoiding awkward expectAsync calls)
Future<void> forEach<T>(List<T> docs, Future<void> tester(T e)) =>
    Future.wait(docs.map((e) => tester(e)));
