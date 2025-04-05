import 'package:flutter/material.dart';
import 'package:practice_app/librarian_screen/librarian_home_screen.dart';
import 'package:practice_app/librarian_screen/add_book_screen.dart';
import 'package:practice_app/librarian_screen/issue_return_screen.dart';
import 'package:practice_app/librarian_screen/all_students_screen.dart';

class BookInfo {
  final String id;
  final String name;
  final String authorName;
  final List<String>? genres;
  final int? availableBooks;

  BookInfo({
    required this.id,
    required this.name,
    required this.authorName,
    this.genres,
    this.availableBooks,
  });
}

class AllBooksScreen extends StatefulWidget {
  const AllBooksScreen({super.key});

  @override
  State<AllBooksScreen> createState() => _AllBooksScreenState();
}

class _AllBooksScreenState extends State<AllBooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<BookInfo> books = [
    BookInfo(
      id: '001',
      name: 'Atomic Habits',
      authorName: 'James Clear',
    ),
    BookInfo(
      id: '002',
      name: 'Python Programming',
      authorName: 'Tony F. Charles',
    ),
    BookInfo(
      id: '003',
      name: 'The Hobbit',
      authorName: 'J.J.R. Tolkien',
      genres: ['Fantasy', 'Adventure', 'Popular'],
      availableBooks: 3,
    ),
    BookInfo(
      id: '004',
      name: 'Encyclopedia of Gardening',
      authorName: 'T.W. sanders, F.L.S.',
    ),
    BookInfo(
      id: '005',
      name: 'Dead Star',
      authorName: 'James Clear',
    ),
  ];

  List<BookInfo> filteredBooks = [];

  @override
  void initState() {
    super.initState();
    filteredBooks = books;
    _searchController.addListener(_filterBooks);
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredBooks = books.where((book) {
        return book.id.toLowerCase().contains(query) ||
            book.name.toLowerCase().contains(query) ||
            book.authorName.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Widget _buildBookCard(BookInfo book) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book ID: ${book.id}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Name: ${book.name}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Author\'s Name: ${book.authorName}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        children: [
          if (book.genres != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Genres:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.genres!.join(', '),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (book.availableBooks != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Books:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.availableBooks}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement books issued functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Books Issued',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE8C6),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 60, bottom: 16),
            child: Row(
              children: [
                Icon(
                  Icons.library_books,
                  color: Colors.orange,
                  size: 32,
                ),
                SizedBox(width: 8),
                Text(
                  'All Books In Library',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Book ID/Book or Author\'s Name',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Colors.orange),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                return _buildBookCard(filteredBooks[index]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () =>
                    _navigateToScreen(context, const LibrarianHomeScreen()),
                child: _buildNavItem(icon: Icons.home, label: 'Home'),
              ),
              GestureDetector(
                onTap: () => _navigateToScreen(context, const AddBookScreen()),
                child: _buildNavItem(icon: Icons.add_box, label: 'Add Book'),
              ),
              GestureDetector(
                onTap: () =>
                    _navigateToScreen(context, const IssueReturnScreen()),
                child: _buildNavItem(
                    icon: Icons.swap_horiz, label: 'Issue/Return'),
              ),
              GestureDetector(
                onTap: () =>
                    _navigateToScreen(context, const AllStudentsScreen()),
                child: _buildNavItem(icon: Icons.people, label: 'All Students'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.orange : Colors.grey,
        ),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.orange : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
