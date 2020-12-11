import 'package:flutter_test/flutter_test.dart';

import 'test_doc_info.dart';

Matcher infoMatches(TestDocInfo info) => _TestDocInfoMatcher(info);

class _TestDocInfoMatcher extends Matcher {
  final TestDocInfo expected;

  _TestDocInfoMatcher(this.expected) {
    assert(this.expected != null);
  }

  @override
  Description describe(Description description) =>
      description.add(expected.toString());

  @override
  bool matches(item, Map matchState) => item is TestDocInfo && item == expected;
}
