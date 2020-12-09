import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_text/pdf_text.dart';

import 'doc_info.dart';

Matcher infoMatches(DocInfo info) => _InfoMatcher(info);

class _InfoMatcher extends Matcher {

  final DocInfo expected;

  _InfoMatcher(this.expected){
    assert(this.expected != null);
  }

  @override
  Description describe(Description description) => description.add(expected.toString());

  @override
  bool matches(item, Map matchState) {
    PDFDocInfo actual = item as PDFDocInfo;
    return expected.title != null ? expected.title == actual.title : true &&
      expected.subject != null ? expected.subject == actual.subject : true &&
      expected.creator != null ? expected.creator == actual.creator : true &&
      expected.author != null ? expected.author == actual.author : true &&
      expected.producer != null ? expected.producer == actual.producer : true &&
      expected.keywords != null ? expected.keywords == actual.keywords.join(",") : true &&
      expected.createdDate != null ? (expected.createdDate.millisecondsSinceEpoch - actual.creationDate.microsecondsSinceEpoch).abs() < 1000 : true;
  }
}