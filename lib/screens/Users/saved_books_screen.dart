import 'package:book_world/models/book_model.dart';
import 'package:book_world/services/book_service.dart';
import 'package:book_world/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:book_world/routes/route_names.dart';
import 'package:get/get.dart';


class SavedBooksScreen extends StatefulWidget {
  const SavedBooksScreen({super.key});

  @override
  State<SavedBooksScreen> createState() => _SavedBooksScreenState();
}

class _SavedBooksScreenState extends State<SavedBooksScreen> {
  final BookService _bookService = BookService();
  final SupabaseClient _supabase = Supabase.instance.client;
  List<BookModel> _savedBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSavedBooks();
  }

  Future<void> _fetchSavedBooks() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      final response = await _supabase
          .from('saved_books')
          .select('book_id, books(*)')
          .eq('user_id', userId!);

      final List<BookModel> books = response
          .map<BookModel>((record) => BookModel.fromJson(record['books']))
          .toList();

      setState(() {
        _savedBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching saved books: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Your Saved Books"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _savedBooks.isEmpty
              ? const Center(
                  child: Text(
                    'No saved books yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(right: 16, left: 16, bottom: 5, top: 10),
                  itemCount: _savedBooks.length,
                  itemBuilder: (context, index) {
                    final book = _savedBooks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(26),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(RouteNames.bookDescription, arguments: book);
                            },
                            child: Container(
                              width: 90,
                              height: 145,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: book.coverUrl != null
                                    ? Image.network(
                                        book.coverUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.book, size: 30),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.book, size: 30),
                                      ),
                              ),
                            ),
                          ),                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed(RouteNames.bookDescription, arguments: book);
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                  Text(
                                    book.bookName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'By ${book.authorName}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                    ]
                                                              ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.lightGreen,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Borrow'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    if (book.isEbook)
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Read'),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAllNamed(RouteNames.home);
              break;
            case 2:
              Get.toNamed(RouteNames.borrowedBooks);
              break;
            case 3:
              Get.toNamed(RouteNames.account);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Borrowed'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
  }
