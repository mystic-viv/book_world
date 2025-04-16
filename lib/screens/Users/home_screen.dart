import 'package:book_world/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _searchBooks(String query) {
    // Implement search functionality
    debugPrint('Searching for: $query');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "BOOK WORLD",
          style: TextStyle(
            color: Colors.orange,
            fontFamily: 'Sanchez',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline, color: Colors.orange),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildGenresSection(),
              const SizedBox(height: 20),
              _buildAgeCategories(),
              const SizedBox(height: 20),
              _buildRecentlyInteractedBooks(),
              const SizedBox(height: 20),
              _buildTopExploredBooks(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              Get.toNamed(RouteNames.savedBooks);
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

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search books...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
              ),
              onSubmitted: _searchBooks,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _searchBooks(_searchController.text),
          child: Container(
            height: 45,
            width: 45,
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildGenresSection() {
    // List of all available genres with their icons
    final List<Map<String, dynamic>> allGenres = [
      {'title': 'Biographies', 'icon': Icons.contact_page},
      {'title': 'Literature', 'icon': Icons.feed},
      {'title': 'Engineering', 'icon': Icons.engineering},
      {'title': 'History', 'icon': Icons.history_edu},
      {'title': 'Law', 'icon': Icons.gavel},
      {'title': 'Fantasy', 'icon': Icons.auto_stories},
      {'title': 'Science', 'icon': Icons.science},
      {'title': 'Fiction', 'icon': Icons.menu_book},
      {'title': 'Self-Help', 'icon': Icons.psychology},
      {'title': 'Business', 'icon': Icons.business},
      {'title': 'Technology', 'icon': Icons.computer},
      {'title': 'Art', 'icon': Icons.palette},
      {'title': 'Poetry', 'icon': Icons.format_quote},
      {'title': 'Cooking', 'icon': Icons.restaurant},
      {'title': 'Travel', 'icon': Icons.flight},
      {'title': 'Sports', 'icon': Icons.sports_soccer},
      {'title': 'Mystery', 'icon': Icons.search},
      {'title': 'Romance', 'icon': Icons.favorite},
      {'title': 'Thriller', 'icon': Icons.bolt},
      {'title': 'Horror', 'icon': Icons.dark_mode},
      {'title': 'Comics', 'icon': Icons.photo_album},
      {'title': 'Religion', 'icon': Icons.church},
      {'title': 'Philosophy', 'icon': Icons.psychology_alt},
      {'title': 'Medicine', 'icon': Icons.medical_services},
    ];
  
    // Shuffle the genres list to display them randomly
    final List<Map<String, dynamic>> shuffledGenres = List.from(allGenres)..shuffle();
  
    // Calculate how many genres can fit in one row
    // Assuming each genre item takes about 70-80 pixels width including spacing
    final int genresPerRow = (MediaQuery.of(context).size.width - 32) ~/ 60;
  
    // Take only the number of genres that can fit in one row
    final List<Map<String, dynamic>> displayedGenres = shuffledGenres.take(genresPerRow).toList();
  
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Genres',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            TextButton(
              onPressed: () {
                // Show popup with all genres
                _showAllGenresDialog(context, allGenres);
              },
              child: const Text(
                'View all',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: displayedGenres.map((genre) => 
            _genreItem(genre['title'], genre['icon'])
          ).toList(),
        ),
      ],
    );
  }

  // Method to show the popup with all genres
  void _showAllGenresDialog(BuildContext context, List<Map<String, dynamic>> allGenres) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.orange, width: 2),
          ),
          backgroundColor: const Color(0xFFFFE8C6),
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 17, top: 10, bottom: 5),
                      child: const Text(
                        'All Genres',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ), 
                  ],
                ),
                
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: allGenres.map((genre) => 
                        _genreItem(genre['title'], genre['icon'])
                      ).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

  }  Widget _genreItem(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Navigate to genre-specific book list
        print('Selected genre: $title');
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.orange, size: 30),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
  Widget _buildAgeCategories() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[100],
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Kids', style: TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[100],
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Teens',
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyInteractedBooks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recently Interacted Books',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View all',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        SizedBox(
          // For 1:1.5 aspect ratio, height = width * 1.5
          height: (MediaQuery.of(context).size.width - 32 - 20) / 3 * 1.5,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) {
              // Set the width to match the grid items (screen width / 3 - spacing)
              final itemWidth = (MediaQuery.of(context).size.width - 32 - 20) / 3;
            
              return Container(
                width: itemWidth,
                margin: const EdgeInsets.only(right: 10),
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
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.book,
                            size: 30,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Book ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Author ${index + 1}',
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
              );
            },
          ),
        ),
      ],
    );
  }
  Widget _buildTopExploredBooks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top Explored Books',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View all',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        // Grid view for Top Explored Books with 3 columns
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1/1.5, // Set aspect ratio to 1:1.5 (width:height)
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 9, // Display 9 books (3 rows of 3)
          itemBuilder: (context, index) {
            return Container(
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
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.book,
                          size: 30,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Author ${index + 1}',
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
            );
          },
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