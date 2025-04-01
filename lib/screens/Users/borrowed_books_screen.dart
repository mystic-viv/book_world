import 'package:book_world/routes/route_names.dart';
import 'package:book_world/screens/Users/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class BorrowedBooksScreen extends StatelessWidget {
  const BorrowedBooksScreen({super.key});

  Widget _buildBookCard({
    required String title,
    required String author,
    required String imageUrl,
    String? daysLeft,
    String? booksLeft,
    DateTime? submittedDate,
    bool showRenew = false,
    bool showReBorrow = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover Image
          Container(
            width: 100,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Book Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'By $author',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                if (submittedDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Submitted on ${submittedDate.day} Jan, ${submittedDate.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                if (daysLeft != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '$daysLeft days left',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (booksLeft != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '$booksLeft Books left',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                // Action Buttons
                Row(
                  children: [
                    if (showRenew)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Renew'),
                        ),
                      ),
                    if (showRenew) const SizedBox(width: 8),
                    if (showReBorrow)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Re-Borrow'),
                        ),
                      ),
                    if (showReBorrow || showRenew) const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Borrowed Books",
          style: TextStyle(
            color: Colors.orange,
            fontFamily: 'Sanchez',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBookCard(
              title: 'Red Star',
              author: 'John Doe',
              imageUrl: 'assets/Red Star book v2.jpg',
              daysLeft: null,
              booksLeft: '6',
              showRenew: true,
            ),
            _buildBookCard(
              title: 'Bhagavad Geeta',
              author: 'Ved Vyasa',
              imageUrl: 'assets/Bhagavad Geeta book.jpg',
              daysLeft: '5',
            ),
            _buildBookCard(
              title: 'Dead Star',
              author: 'Jane Smith',
              imageUrl: 'assets/DeadStar book v1.jpg',
              submittedDate: DateTime(2025, 1, 25),
              booksLeft: '2',
              showReBorrow: true,
            ),
            _buildBookCard(
              title: 'Indian History',
              author: 'Dr. Ramesh Kumar',
              imageUrl: 'assets/Indian History book.jpg',
              daysLeft: '8',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to HomeScreen and remove all previous routes using Get
              Get.offAll(() => const HomeScreen());
              break;
            case 1:
              Get.toNamed(RouteNames.savedBooks);
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
