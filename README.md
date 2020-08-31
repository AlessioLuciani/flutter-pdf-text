# PDF Text Plugin

[![Pub Version](https://img.shields.io/pub/v/pdf_text)](https://pub.dev/packages/pdf_text)
[![GitHub issues](https://img.shields.io/github/issues/AlessioLuciani/flutter-pdf-text)](https://github.com/AlessioLuciani/flutter-pdf-text/issues)
[![GitHub forks](https://img.shields.io/github/forks/AlessioLuciani/flutter-pdf-text)](https://github.com/AlessioLuciani/flutter-pdf-text/network)
[![GitHub stars](https://img.shields.io/github/stars/AlessioLuciani/flutter-pdf-text)](https://github.com/AlessioLuciani/flutter-pdf-text/stargazers)
[![GitHub license](https://img.shields.io/github/license/AlessioLuciani/flutter-pdf-text)](https://github.com/AlessioLuciani/flutter-pdf-text/blob/master/LICENSE)

This plugin for [Flutter](https://flutter.dev) allows you to read the text content of PDF documents and convert it into strings. It works on iOS and Android. On iOS it uses Apple's [PDFKit](https://developer.apple.com/documentation/pdfkit). On Android it uses Apache's [PdfBox](https://github.com/TomRoush/PdfBox-Android) Android porting.

<p align="center">
  <img src="https://raw.githubusercontent.com/AlessioLuciani/flutter-pdf-text/master/example/flutter-pdf-text.gif" alt="Demo Example App" style="margin:auto"  width="250"  height="550">
</p>

## Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  pdf_text: ^0.3.1
```

## Usage

Import the package with:

```dart
import 'package:pdf_text/pdf_text.dart';
```

*Create a PDF document instance using a File object:*

```dart
PDFDoc doc = await PDFDoc.fromFile(file);
```

or using a path string:

```dart
PDFDoc doc = await PDFDoc.fromPath(path);
```

or using a URL string:

```dart
PDFDoc doc = await PDFDoc.fromURL(url);
```

Pass a password for encrypted PDF documents:

```dart
PDFDoc doc = await PDFDoc.fromFile(file, password: password);
```

Use faster initialization on Android:

```dart
PDFDoc doc = await PDFDoc.fromFile(file, fastInit: true);
```

*Read the text of the entire document:*

```dart
String docText = await doc.text;
```

Retrieve the number of pages of the document:

```dart
int numPages = doc.length;
```

*Access a page of the document:*

```dart
PDFPage page = doc.pageAt(pageNumber);
```

*Read the text of a page of the document:*

```dart
String pageText = await page.text;
```

*Read the information of the document:*

```dart
PDFDocInfo info = doc.info;
```

Optionally, you can delete the file of a document when you no longer need it.
This can be useful when you import a PDF document from outside the local
file system (e.g using a URL), since it is automatically stored in the temporary
directory of the app.

Delete the file of a single document:

```dart
doc.deleteFile();
```

or delete all the files of all the documents imported from outside the local
file system:

```dart
PDFDoc.deleteAllExternalFiles();
```

## Functioning

This plugin applies lazy loading for the text contents of the pages. The text is cached page per page. When you request the text of a page for the first time, it is parsed and stored in memory, so that the second access will be faster. Anyway, the text of pages that are not requested is not loaded. This mechanism
allows you not to waste time loading text that you will probably not use. When you request the text content of the entire document, only the pages that have not been loaded yet are then loaded.

## Public Methods
  
### PDFDoc

| Return  | Description  |
|---|---|
| PDFPage | **pageAt(int pageNumber)** <br> Gets the page of the document at the given page number. |
| static Future\<PDFDoc> | **fromFile(File file, {String password = "", bool fastInit = false})** <br> Creates a PDFDoc object with a File instance. Optionally, takes a password for encrypted PDF documents. If fastInit is true, the initialization of the document will be faster on Android. In that case, the text stripper engine will not be initialized with this call, but later when some text is read. This means that the first text read will take some time but the document data can be accessed immediately.|
| static Future\<PDFDoc> | **fromPath(String path, {String password = "", bool fastInit = false})** <br> Creates a PDFDoc object with a file path. Optionally, takes a password for encrypted PDF documents. If fastInit is true, the initialization of the document will be faster on Android. In that case, the text stripper engine will not be initialized with this call, but later when some text is read. This means that the first text read will take some time but the document data can be accessed immediately.|
| static Future\<PDFDoc> | **fromURL(String url, {String password = "", bool fastInit = false})** <br> Creates a PDFDoc object with a url. Optionally, takes a password for encrypted PDF documents. If fastInit is true, the initialization of the document will be faster on Android. In that case, the text stripper engine will not be initialized with this call, but later when some text is read. This means that the first text read will take some time but the document data can be accessed immediately. It downloads the PDF file located in the given URL and saves it in the app's temporary directory. |
| void | **deleteFile()** <br> Deletes the file related to this PDFDoc.<br>Throws an exception if the FileSystemEntity cannot be deleted. |
| static Future | **deleteAllExternalFiles()** <br> Deletes all the files of the documents that have been imported from outside the local file system (e.g. using fromURL). |

## Objects

```dart
class PDFDoc {
  int length; // Number of pages of the document
  List<PDFPage> pages; // Pages of the document
  Future<String> text; // Text of the document
}

class PDFPage {
  int number; // Number of the page in the document
  Future<String> text; // Text of the page
}

class PDFDocInfo {
  String author; // Author string of the document
  List<String> authors; // Authors of the document
  DateTime creationDate; // Creation date of the document
  DateTime modificationDate; // Modification date of the document
  String creator; // Creator of the document
  String producer; // Producer of the document
  List<String> keywords; // Keywords of the document
  String title; // Title of the document
  String subject; // Subject of the document
}
```

## Contribute

If you have any suggestions, improvements or issues, feel free to contribute to this project.
You can either submit a new issue or propose a pull request.
