import 'package:book_world/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:book_world/models/book_model.dart';
import 'package:get/route_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GenreBooksScreen extends StatefulWidget {
  final String genre;
  final IconData icon;

  const GenreBooksScreen({
    Key? key,
    required this.genre,
    required this.icon,
    required List<BookModel> results,
  }) : super(key: key);

  @override
  State<GenreBooksScreen> createState() => _GenreBooksScreenState();
}

class _GenreBooksScreenState extends State<GenreBooksScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<BookModel> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBooksByGenre();
  }

  Future<void> _fetchBooksByGenre() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      // Query books that contain this genre in their genres array
      final response = await _supabase
          .from('books')
          .select()
          .contains('genres', [widget.genre])
          .order('book_name', ascending: true);

      final List<BookModel> books =
          response.map<BookModel>((book) => BookModel.fromJson(book)).toList();

      if (mounted) {
        setState(() {
          _books = books;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching books by genre: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(widget.icon, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            Text(
              widget.genre,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
              : _books.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No books found in ${widget.genre}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Found ${_books.length} book${_books.length == 1 ? '' : 's'} in ${widget.genre}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1 / 1.5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: _books.length,
                        itemBuilder: (context, index) {
                          final book = _books[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to book details (to be implemented)
                              Get.toNamed(
                                RouteNames.bookDescription,
                                arguments: book,
                              );
                              debugPrint('Selected book: ${book.bookName}');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
                                        child:
                                            book.coverUrl != null
                                                ? Image.network(
                                                  book.coverUrl!,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.fitWidth,
                                                  alignment:
                                                      Alignment.topCenter,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Center(
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        size: 30,
                                                        color: Colors.grey[600],
                                                      ),
                                                    );
                                                  },
                                                )
                                                : Center(
                                                  child: Icon(
                                                    Icons.book,
                                                    size: 30,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book.bookName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          book.authorName,
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
