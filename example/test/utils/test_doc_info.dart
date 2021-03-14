import 'package:pdf_text/pdf_text.dart';

class TestDocInfo {
  final String? title;
  final String? author;
  final String? creator;
  final String? subject;
  final String? keywords;

  /// On the limitations and "features " of the pdf library used for creating
  /// test documents -> (https://github.com/DavBfr/dart_pdf)

  /// 1) The producer field is not tested, because the library uses this field to
  /// set/append the link to its github repo.

  /// 2) The library, does not allow to set the createdTime explicitly,
  /// instead it calls DateTime.now(), preprocesses the result and uses it
  /// to save in the pdf document being created.
  /// For example: If a call to DateTime.now() returns 2020-12-09 23:02:35.861548
  /// the library will save it in the document in the 12 hour format with the
  /// milliseconds part truncated (2020-12-09 11:02:35.000).
  /// Because of that, checks of createdDate in the tests will be omitted as well.

  TestDocInfo(
      {this.title, this.author, this.creator, this.subject, this.keywords});

  TestDocInfo.fromPDFDocInfo(PDFDocInfo pdfDocInfo)
      : this.title = pdfDocInfo.title,
        this.author = pdfDocInfo.author,
        this.creator = pdfDocInfo.creator,
        this.subject = pdfDocInfo.subject,
        this.keywords = pdfDocInfo.keywords!.join(",");

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestDocInfo &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          author == other.author &&
          creator == other.creator &&
          subject == other.subject &&
          keywords == other.keywords;

  @override
  int get hashCode =>
      title.hashCode ^
      author.hashCode ^
      creator.hashCode ^
      subject.hashCode ^
      keywords.hashCode;

  @override
  String toString() => 'DocInfo{title: $title, '
      'author: $author, '
      'creator: $creator, '
      'subject: $subject, '
      'keywords: $keywords}';
}
