@Skip(
    'To run these tests, make sure an emulator or a real device is connected, then \'cd example\' and : \'flutter run test/pdf_text_test.dart\'')
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:pdf_text/client_provider.dart';
import 'utils/pdf_test_utils.dart';
import 'utils/test_doc_info.dart';
import 'utils/text_matcher.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testDirectoryPath =
      join((await getTemporaryDirectory()).path, "temp_pdf_text_dir");
  final PdfTestUtils pdfUtils = PdfTestUtils(testDirectoryPath);
  final File encryptedPdf = File(join(testDirectoryPath, "encrypted.pdf"));

  setUpAll(() async {
    /// init mock http client so that the PDFDoc.fromUrl() obtains the mocked version
    ClientProvider(
        client: MockClient((Request req) => Future.value(Response.bytes(
            File(join(testDirectoryPath, req.url.path.split("/").last))
                .readAsBytesSync(),
            200))));
    Directory(testDirectoryPath).createSync();

    /// Copy the content of encrypted.pdf to the test directory
    final byteData = await rootBundle.load('test/resources/encrypted.pdf');
    encryptedPdf.writeAsBytesSync(byteData.buffer.asUint8List());
  });

  tearDownAll(() {
    try {
      Directory(testDirectoryPath).deleteSync(recursive: true);
    } catch (e) {
      debugPrint(
          "Exception while attempting to delete test directory (no big deal) : $e");
    }
  });

  group("PDFDoc.from[File, Path, Url]", () {
    test("should read text from a single-page pdf document", () async {
      final info = TestDocInfo(
          title: "Summa Theologiae",
          author: "St Thomas Aquinas",
          creator: "PDF Creator",
          subject: "The most profound theological book ever written",
          keywords: "Doctor,Angelicus");

      List<String> page = [
        "Et ut intentio nostra sub aliquibus certis limitibus comprehendatur,",
        "necessarium est primo investigare de ipsa sacra doctrina, qualis sit, et ad quæ se extendat.",
        "Circa quæ quærenda sunt decem.",
        "Primo, de necessitate huius doctrinæ.",
        "Secundo, utrum sit scientia.",
        "Tertio, utrum sit una vel plures."
      ];

      File pdf = await pdfUtils.createPdfFile([page], info: info);

      PDFDoc fromFile = await PDFDoc.fromFile(pdf);
      PDFDoc fromPath = await PDFDoc.fromPath(pdf.path);
      PDFDoc fromUrl =
          await PDFDoc.fromURL("http://localhost/${basename(pdf.path)}");

      await forEach([fromFile, fromPath, fromUrl], (dynamic doc) async {
        expect(await doc.text, textMatches(page));
        expect(doc.pages.length, 1);
        expect(await doc.pages.first.text, textMatches(page));
        expect(TestDocInfo.fromPDFDocInfo(doc.info), info);
      });

      fromPath.deleteFile();
      expect(pdf.existsSync(), false);
    });

    test("should read text from a multi-page pdf document", () async {
      final info = TestDocInfo(
          title: "Sherlock Holmes series",
          author: "Sr Arthur Conan Doyle",
          creator: "PDF Creator",
          subject: "Detecitve stories",
          keywords: "Holmes,Watson");

      List<String> page1 = [
        "To Sherlock Holmes she is always the woman.",
        "I have seldom heard him mention her under any other name.",
        "In his eyes she eclipses and predominates the whole of her sex.",
      ];

      List<String> page2 = [
        "himself in a false position. He never spoke of the softer",
        "They were admirable things for the observer-excellent for",
        "But for the trained reasoner to admit such intrusions into",
        "was to introduce a distracting factor which might throw a",
      ];

      File pdf = await pdfUtils.createPdfFile([page1, page2], info: info);

      PDFDoc fromFile = await PDFDoc.fromFile(pdf);
      PDFDoc fromPath = await PDFDoc.fromPath(pdf.path);
      PDFDoc fromUrl =
          await PDFDoc.fromURL("http://localhost/${basename(pdf.path)}");

      await forEach([fromFile, fromPath, fromUrl], (dynamic doc) async {
        expect(doc.pages.length, 2);
        expect(await doc.pageAt(1).text, textMatches(page1));
        expect(await doc.pageAt(2).text, textMatches(page2));
        expect(TestDocInfo.fromPDFDocInfo(doc.info), info);
        expect(await doc.text, textMatches([...page1, ...page2]));
      });

      fromFile.deleteFile();
      expect(pdf.existsSync(), false);
    });

    test("should read text from a password protected pdf file", () async {
      expect(encryptedPdf.existsSync(), true);

      PDFDoc fromFile =
          await PDFDoc.fromFile(encryptedPdf, password: "password");
      PDFDoc fromPath =
          await PDFDoc.fromPath(encryptedPdf.path, password: "password");
      PDFDoc fromUrl = await PDFDoc.fromURL(
          "http://localhost/${basename(encryptedPdf.path)}",
          password: "password");

      final expectedContent = "Hello World! (from an encrypted pdf document)";

      await forEach([fromFile, fromPath, fromUrl], (dynamic doc) async {
        expect(await doc.pageAt(1).text, textMatches([expectedContent]));
        expect(await doc.text, textMatches([expectedContent]));
      });
    });

    test("should fail if the password is invalid", () async {
      expect(encryptedPdf.existsSync(), true);

      int exceptionCount = 0;

      final fromFile =
          () => PDFDoc.fromFile(encryptedPdf, password: "invalid-password");
      final fromPath = () =>
          PDFDoc.fromPath(encryptedPdf.path, password: "invalid-password");
      final fromURL = () => PDFDoc.fromURL(
          "http://localhost/${basename(encryptedPdf.path)}",
          password: "invalid-password");

      await forEach([fromFile, fromPath, fromURL], (dynamic foo) async {
        try {
          await foo();
        } on PlatformException catch (e) {
          expect(
              e.message,
              contains(isIos
                  ? "The password is invalid"
                  : "File path or password (in case of encrypted document) is invalid"));
          exceptionCount++;
        } catch (e) {
          fail("should not get here!");
        }
      });

      expect(exceptionCount, 3,
          reason: "All attempts with invalid password must fail!");
    });
  });
}
