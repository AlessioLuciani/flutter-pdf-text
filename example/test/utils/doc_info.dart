class DocInfo {
  final String title;
  final String author;
  final String creator;
  final String subject;
  final String keywords;
  final String producer;
  final DateTime createdDate;
  DocInfo({this.title, this.author, this.creator, this.subject, this.keywords, this.producer, this.createdDate});

  @override
  String toString() {
    return 'DocInfo{title: $title, author: $author, creator: $creator, subject: $subject, keywords: $keywords, producer: $producer, createdDate: $createdDate}';
  }
}
