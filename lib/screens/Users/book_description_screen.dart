import 'package:book_world/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:book_world/services/book_service.dart';
import 'package:get/route_manager.dart';

class BookDescriptionScreen extends StatefulWidget {
  final BookModel book;

  const BookDescriptionScreen({super.key, required this.book});

  @override
  State<BookDescriptionScreen> createState() => _BookDescriptionScreenState();
}

class _BookDescriptionScreenState extends State<BookDescriptionScreen> {
  final BookService _bookService = BookService();
  List<BookModel> _similarBooks = [];
  bool _isLoading = true;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _fetchSimilarBooks();
    _checkIfBookIsSaved();
    _recordBookView();
  }

  Future<void> _recordBookView() async {
    await _bookService.recordBookInteraction(widget.book.id, 'view');
  }


  Future<void> _checkIfBookIsSaved() async {
    final isSaved = await _bookService.isBookSaved(widget.book.id);
    if (mounted) {
      // Add this check
      setState(() {
        _isSaved = isSaved;
      });
    }
  }

  Future<void> _toggleSave() async {
    if (_isLoading) return;

   if (mounted) {
      // Add this check
      setState(() => _isLoading = true);
    }
    try {
      if (_isSaved) {
        await _bookService.unsaveBook(widget.book.id);
      } else {
        await _bookService.saveBook(widget.book.id);
      }
       if (mounted) {
        // Add this check
        setState(() => _isSaved = !_isSaved);
      }
      ;
    } catch (e) {
      debugPrint('Error toggling save: $e');
    }
    if (mounted) {
      // Add this check
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSimilarBooks() async {
    if (widget.book.genres == null || widget.book.genres!.isEmpty) {
       if (mounted) {
        // Add this check
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final similarBooks = await _bookService.getSimilarBooks(
        bookId: widget.book.id,
        genres: widget.book.genres!,
        limit: 10,
      );

       if (mounted) {  // Add this check
      setState(() {
        _similarBooks = similarBooks;
        _isLoading = false;
      });
    }
    } catch (e) {
      debugPrint('Error fetching similar books: $e');
      if (mounted) {
        // Add this check
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
            onPressed: () => Get.back(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.orange),
              onPressed: () {
                // Implement share functionality
              },
            ),
          ),
        ],
        backgroundColor: const Color(0xFFFFE8C6),
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover and Info Section
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFFE8C6), Colors.white],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Book Cover with Shadow
                        Container(
                          width: 130,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                widget.book.coverUrl != null
                                    ? Image.network(
                                      widget.book.coverUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.book,
                                            size: 50,
                                          ),
                                        );
                                      },
                                    )
                                    : Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.book, size: 50),
                                    ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Book Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.book.bookName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'By ${widget.book.authorName}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Availability Status
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      widget.book.availableCopies > 0
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.book.availabilityStatus,
                                  style: TextStyle(
                                    color:
                                        widget.book.availableCopies > 0
                                            ? Colors.green
                                            : Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              // Genre Tags
                              if (widget.book.genres != null &&
                                  widget.book.genres!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children:
                                      widget.book.genres!.map((genre) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            genre,
                                            style: const TextStyle(
                                              color: Colors.orange,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Bookmark button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _isLoading ? null : _toggleSave,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _isLoading 
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.orange,
                                  ),
                                )
                              : Icon(
                                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                                  color: Colors.orange,
                                  size: 24,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              widget.book.availableCopies > 0
                                  ? () {
                                    // Implement borrow functionality
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Borrow',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (widget.book.isEbook)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Implement read functionality
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Read',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Description Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About This Book',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.book.description,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.grey[650],
                        ),
                      ),
                      if (widget.book.publicationYear != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Publication Year: ${widget.book.publicationYear}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),

                      // Similar Books Section
                      const Text(
                        'Similar Books',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8C6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            _isLoading
                                ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(
                                      color: Colors.orange,
                                    ),
                                  ),
                                )
                                : _similarBooks.isEmpty
                                ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      'No similar books found',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                                : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children:
                                        _similarBooks.map((similarBook) {
                                          int matchingGenres =
                                              similarBook.genres
                                                  ?.where(
                                                    (g) => widget.book.genres!
                                                        .contains(g),
                                                  )
                                                  .length ??
                                              0;

                                          return Tooltip(
                                            message:
                                                '$matchingGenres matching ${matchingGenres == 1 ? 'genre' : 'genres'}',
                                            child: SimilarBookCard(
                                              imageUrl:
                                                  similarBook.coverUrl ?? '',
                                              title: similarBook.bookName,
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                      ),
                      const SizedBox(height: 32),

                      // Ratings Section
                      const Text(
                        'Ratings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ReviewCard(
                        name: 'Vivek Sharma',
                        date: 'Jan 1, 2025',
                        rating: 4,
                      ),
                      const ReviewCard(
                        name: 'Shunham Ganvani',
                        date: 'Jan 1, 2025',
                        rating: 4,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SimilarBookCard extends StatelessWidget {
  final String imageUrl;
  final String title;

  const SimilarBookCard({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, size: 30),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String name;
  final String date;
  final int rating;

  const ReviewCard({
    super.key,
    required this.name,
    required this.date,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 20,
              );
            }),
          ),
        ],
      ),
    );
  }
}