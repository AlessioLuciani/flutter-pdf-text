import 'package:flutter_test/flutter_test.dart';

import 'pdf_test_utils.dart';

Matcher textMatches(List<String> lines) => _TextMatcher(lines);

class _TextMatcher extends Matcher {
  final List<String> expected;

  _TextMatcher(this.expected);

  @override
  Description describe(Description description) => description.add(_expected);

  String get _expected => expected.join(isIos ? " " : "\n").trim();

  @override
  bool matches(item, Map matchState) {
    String? actual = item as String?;

    /// For iOS (where the PDFKit is used) positioning of new lines in the text seem not to be
    /// very predictable, so for the purpose of the test the \n get replaced with a single space
    /// in both expected (see above) and actual content and only then checked for equality.
    return isIos
        ? actual!.replaceAll(RegExp("\n"), " ").trim() == _expected
        : actual!.trim() == _expected;
  }
}
