class BookModel {
  final String id; // UUID internal ID
  final String customId; // Custom ID (BWB-XXX format)
  final String bookName;
  final String authorName; // Direct author name instead of separate model
  final String description;
  final String? coverUrl;
  final String? pdfUrl;
  final List<String>? genres;
  final int totalCopies;
  final int availableCopies;
  final int? publicationYear;
  final String? addedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEbook; // Add this field

  BookModel({
    required this.id,
    required this.customId,
    required this.bookName,
    required this.authorName,
    required this.description,
    this.coverUrl,
    this.pdfUrl,
    required this.totalCopies,
    required this.availableCopies,
    this.genres,
    this.publicationYear,
    this.addedBy,
    required this.createdAt,
    required this.updatedAt,
    this.isEbook = false,
  });

  // Create from JSON (from Supabase)
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      customId: json['custom_id'],
      bookName: json['book_name'],
      authorName: json['author_name'],
      description: json['description'] ?? '',
      coverUrl: json['book_cover_url'],
      pdfUrl: json['book_pdf_url'],
      totalCopies: json['total_copies'] ?? 0,
      availableCopies: json['available_copies'] ?? 0,
      genres: json['genres'] != null ? List<String>.from(json['genres']) : null,
      publicationYear: json['publication_year'],
      addedBy: json['added_by'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
      isEbook: json['is_ebook'] ?? false,
    );
  }

  // Convert to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'custom_id': customId,
      'book_name': bookName,
      'author_name': authorName,
      'description': description,
      'book_cover_url': coverUrl,
      'book_pdf_url': pdfUrl,
      'total_copies': totalCopies,
      'available_copies': availableCopies,
      'genres': genres,
      'publication_year': publicationYear,
      'added_by': addedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_ebook': isEbook,
    };
  }

  // Create a copy with updated fields
  BookModel copyWith({
    String? id,
    String? customId,
    String? bookName,
    String? authorId,
    String? authorName,
    String? description,
    String? coverUrl,
    String? ebookUrl,
    int? totalCopies,
    int? availableCopies,
    List<String>? genres,
    int? publicationYear,
    String? addedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEbook,
  }) {
    return BookModel(
      id: id ?? this.id,
      customId: customId ?? this.customId,
      bookName: bookName ?? this.bookName,
      authorName: authorName ?? this.authorName,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      pdfUrl: ebookUrl ?? this.pdfUrl,
      totalCopies: totalCopies ?? this.totalCopies,
      availableCopies: availableCopies ?? this.availableCopies,
      genres: genres ?? this.genres,
      publicationYear: publicationYear ?? this.publicationYear,
      addedBy: addedBy ?? this.addedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEbook: isEbook ?? this.isEbook,
    );
  }

  // Get availability status text
  String get availabilityStatus {
    if (isEbook) return 'E-book Available';
    if (availableCopies > 0)
      return 'Available (${availableCopies}/${totalCopies})';
    return 'Unavailable (0/${totalCopies})';
  }
}
