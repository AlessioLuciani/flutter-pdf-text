# PDF Text Plugin

This plugin for [Flutter](https://flutter.dev) allows you to read the text content of PDF documents and convert it into strings. The plugin works on iOS and Android. On iOS it uses Apple's [PDFKit](https://developer.apple.com/documentation/pdfkit). On Android it uses Apache's [PdfBox](https://github.com/TomRoush/PdfBox-Android) Android porting.

## Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  pdf_text: ^0.1.0
```

## Usage

Import the package with:

```dart
import 'package:pdf_text/pdf_text.dart';
```

Create a PDF document instance using a File object:

```dart
PDFDoc doc = await PDFDoc.fromFile(file);
```

or using a path string:

```dart
PDFDoc doc = await PDFDoc.fromPath(path);
```

Read the text of the entire document:

```dart
String docText = await doc.text;
```

Retrieve the number of pages of the document:

```dart
int numPages = doc.length;
```

Access a page of the document:

```dart
PDFPage page = doc.pageAt(pageNumber);
```

Read the text of a page of the document:

```dart
String pageText = await page.text;
```

## Public Methods
  
### PDFDoc

| Return  | Description  |

| PDFPage | **pageAt(int pageNumber)** <br> Gets the page of the document at the given page number. |

| static Future\<PDFDoc> | **fromFile(File file)** <br> Creates a PDFDoc object with a File instance. |

| static Future\<PDFDoc> | **fromPath(String path)** <br> Creates a PDFDoc object with a file path. |

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
```

## Contribute

If you have any suggestions, improvements or issues, feel free to contribute to this project.
You can either submit a new issue or propose a pull request.