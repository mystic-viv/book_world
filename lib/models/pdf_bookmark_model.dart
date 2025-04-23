class PDFBookmark {
  final String? id;
  final String bookId;
  final int pageNumber;
  final String title;
  final DateTime createdAt;

  PDFBookmark({
    this.id,
    required this.bookId,
    required this.pageNumber,
    required this.title,
    required this.createdAt,
  });

  factory PDFBookmark.fromJson(Map<String, dynamic> json) {
    return PDFBookmark(
      id: json['id'],
      bookId: json['bookId'] ?? json['book_id'],
      pageNumber: json['pageNumber'] ?? json['page_number'],
      title: json['title'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : (json['created_at'] != null
                  ? DateTime.parse(json['created_at'])
                  : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'pageNumber': pageNumber,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert to database format
  Map<String, dynamic> toDbJson() {
    return {
      'id': id,
      'book_id': bookId,
      'page_number': pageNumber,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}

class PDFReadingProgress {
  final String bookId;
  final int lastReadPage;
  final DateTime lastReadTime;

  PDFReadingProgress({
    required this.bookId,
    required this.lastReadPage,
    required this.lastReadTime,
  });

  factory PDFReadingProgress.fromJson(Map<String, dynamic> json) {
    return PDFReadingProgress(
      bookId: json['bookId'] ?? json['book_id'],
      lastReadPage: json['lastReadPage'] ?? json['last_read_page'],
      lastReadTime:
          json['lastReadTime'] != null
              ? DateTime.parse(json['lastReadTime'])
              : (json['last_read_time'] != null
                  ? DateTime.parse(json['last_read_time'])
                  : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'lastReadPage': lastReadPage,
      'lastReadTime': lastReadTime.toIso8601String(),
    };
  }

  // Convert to database format
  Map<String, dynamic> toDbJson() {
    return {
      'book_id': bookId,
      'last_read_page': lastReadPage,
      'last_read_time': lastReadTime.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
