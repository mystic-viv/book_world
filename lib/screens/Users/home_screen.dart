import 'package:book_world/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/route_manager.dart';
import 'dart:math' show min, max;
import 'package:book_world/models/book_model.dart';
import 'package:book_world/services/book_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BookService _bookService = BookService();

  List<BookModel> _recentBooks = [];
  List<BookModel> _topBooks = [];
  List<Map<String, dynamic>> _shuffledGenres = [];
  bool _isLoading = true;

  // List of all available genres with their icons
  final List<Map<String, dynamic>> allGenres = [
    {'title': 'Biographies', 'icon': Icons.contact_page},
    {'title': 'Literature', 'icon': Icons.feed},
    {'title': 'Engineering', 'icon': Icons.engineering},
    {'title': 'History', 'icon': Icons.history_edu},
    {'title': 'Law', 'icon': Icons.gavel},
    {'title': 'Fantasy', 'icon': Icons.castle},
    {'title': 'Fiction', 'icon': FontAwesomeIcons.wandMagicSparkles},
    {'title': 'Non-Fiction', 'icon': Icons.book},
    {'title': 'Graphic Novels', 'icon': Icons.auto_stories},
    {'title': 'Comics', 'icon': Icons.photo_album},
    {'title': 'Mystery', 'icon': Icons.search},
    {'title': 'Adventure', 'icon': Icons.explore},
    {'title': 'Sci-Fi', 'icon': Icons.science},
    {'title': 'Psychology', 'icon': Icons.psychology},
    {'title': 'Sprituality', 'icon': FontAwesomeIcons.bookTanakh},
    {'title': 'Self-Improvement', 'icon': Icons.self_improvement},
    {'title': 'Parenting', 'icon': Icons.family_restroom},
    {'title': 'Relationships', 'icon': Icons.people},
    {'title': 'Personal Development', 'icon': Icons.developer_mode},
    {'title': 'Self-Help', 'icon': Icons.psychology},
    {'title': 'Health', 'icon': Icons.health_and_safety},
    {'title': 'Finance', 'icon': Icons.monetization_on},
    {'title': 'Education', 'icon': Icons.school},
    {'title': 'Politics', 'icon': Icons.public},
    {'title': 'Environment', 'icon': Icons.eco},
    {'title': 'Science', 'icon': Icons.science},
    {'title': 'Music', 'icon': Icons.music_note},
    {'title': 'Photography', 'icon': Icons.photo_camera},
    {'title': 'Fashion', 'icon': Icons.checkroom},
    {'title': 'Fitness', 'icon': Icons.fitness_center},
    {'title': 'Gardening', 'icon': Icons.nature_people},
    {'title': 'Architecture', 'icon': Icons.home_repair_service},
    {'title': 'DIY', 'icon': Icons.build},
   // {'title': 'Crafts', 'icon': Icons.crafts},
    {'title': 'Animals', 'icon': Icons.pets},
    {'title': 'Business', 'icon': Icons.business},
    {'title': 'Technology', 'icon': Icons.computer},
    {'title': 'Art', 'icon': Icons.palette},
    {'title': 'Poetry', 'icon': Icons.format_quote},
    {'title': 'Cooking', 'icon': Icons.restaurant},
    {'title': 'Travel', 'icon': Icons.flight},
    {'title': 'Sports', 'icon': Icons.sports_soccer},
    {'title': 'Romance', 'icon': Icons.favorite},
    {'title': 'Thriller', 'icon': Icons.bolt},
    {'title': 'Horror', 'icon': Icons.dark_mode},
    {'title': 'Religion', 'icon': Icons.temple_hindu},
    {'title': 'Philosophy', 'icon': Icons.psychology_alt},
    {'title': 'Medicine', 'icon': Icons.medical_services},
  ];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _shuffleGenres();
  }

  void _shuffleGenres() {
    // Shuffle the genres list to display them randomly
    _shuffledGenres = List.from(allGenres)..shuffle();
  }

  Future<void> _fetchBooks() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get recently interacted books using BookService
      final recentlyInteractedBooks =
          await _bookService.getRecentlyInteractedBooks();

      // Only set _recentBooks if there are actual interactions
      if (recentlyInteractedBooks.isNotEmpty) {
        _recentBooks = recentlyInteractedBooks.take(10).toList();
      } else {
        // Leave _recentBooks as an empty list
        _recentBooks = [];
      }

      // Get top explored books based on interaction counts
      final topExploredBooks = await _bookService.getTopExploredBooks();

      setState(() {
        _topBooks =
            topExploredBooks.take(min(12, topExploredBooks.length)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching books: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchBooks(String query) {
    if (query.trim().isEmpty) return;

    // Show loading indicator
    if(mounted){
       setState(() {
        _isLoading = true;
      });
    }
    /*showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        );
      },
    );*/

    // Use BookService to search books
    _bookService
        .searchBooks(query)
        .then((searchResults) {
          // Close loading indicator
          if(mounted){
            setState(() {
              _isLoading = false;
            });
          }
          /*Navigator.pop(context);*/

          // Navigate to search results screen
          Get.toNamed(RouteNames.searchResults, arguments: {
            'query': query,
            'results': searchResults,
          })!.then((_) {
            // This will run after returning from SearchResultsScreen
            _fetchBooks(); // Refresh books after returning
          });
        })
        .catchError((error) {
          // Close loading indicator
          if(mounted){
            setState(() {
              _isLoading = false;
            });
          }
          /*Navigator.pop(context);*/

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Search failed: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        });
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

      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
              : GestureDetector(
                onTap: () {
                  // Dismiss keyboard when tapping outside of text fields
                  FocusScope.of(context).unfocus();
                },
                child: SingleChildScrollView(
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
              decoration: InputDecoration(
                hintText: 'Search books...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                isDense: true,
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.grey,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                        : null,
                alignLabelWithHint: true,
              ),
              textAlignVertical: TextAlignVertical.center,
              onSubmitted: _searchBooks,
              onChanged: (value) {
                // Trigger rebuild to show/hide clear button
                setState(() {});
              },
              autofocus: false, // Prevent automatic focus
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
    // Calculate how many genres can fit in one row
    // Assuming each genre item takes about 70-80 pixels width including spacing
    final int genresPerRow = (MediaQuery.of(context).size.width - 32) ~/ 60;

    // Take only the number of genres that can fit in one row
    final List<Map<String, dynamic>> displayedGenres =
        _shuffledGenres.take(genresPerRow).toList();

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              displayedGenres
                  .map((genre) => _genreItem(genre['title'], genre['icon']))
                  .toList(),
        ),
      ],
    );
  }

  // Method to show the popup with all genres
  void _showAllGenresDialog(
    BuildContext context,
    List<Map<String, dynamic>> allGenres,
  ) {
    // Define currentPage outside the builder to maintain its state
    int currentPage = 0;

    // Dismiss keyboard when dialog opens
    FocusManager.instance.primaryFocus?.unfocus();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Calculate how many genres per page
            // Assuming 4 genres per row and 4 rows per page
            final int genresPerRow = 4;
            final int rowsPerPage = 4;
            final int genresPerPage = genresPerRow * rowsPerPage;

            // Calculate total number of pages
            final int totalPages = (allGenres.length / genresPerPage).ceil();

            // Create a page controller for swiping
            final PageController pageController = PageController(
              initialPage: currentPage,
            );

            // Get available screen height
            final double screenHeight = MediaQuery.of(context).size.height;
            final double keyboardHeight =
                MediaQuery.of(context).viewInsets.bottom;
            final double availableHeight =
                screenHeight - keyboardHeight - 200; // Subtract some padding

            // Calculate appropriate height for rows
            final double rowHeight = 90; // Default height per row
            final int visibleRows = max(
              1,
              min(rowsPerPage, (availableHeight / rowHeight).floor()),
            );

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.orange, width: 2),
              ),
              backgroundColor: const Color(0xFFFFE8C6),
              insetPadding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                // Add scrolling capability
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 17,
                              top: 10,
                              bottom: 20,
                            ),
                            child: Text(
                              'All Genres',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.orange,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),

                      // PageView for horizontal swiping with adaptive height
                      SizedBox(
                        height: visibleRows * rowHeight,
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: totalPages,
                          onPageChanged: (page) {
                            setState(() {
                              currentPage = page;
                            });
                          },
                          itemBuilder: (context, pageIndex) {
                            // Calculate start and end indices for this page
                            final int startIndex = pageIndex * genresPerPage;
                            final int endIndex =
                                (startIndex + genresPerPage) < allGenres.length
                                    ? startIndex + genresPerPage
                                    : allGenres.length;

                            // Get genres for this page
                            final List<Map<String, dynamic>> pageGenres =
                                allGenres.sublist(startIndex, endIndex);

                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    alignment: WrapAlignment.start,
                                    children:
                                        pageGenres
                                            .map(
                                              (genre) => _genreItem(
                                                genre['title'],
                                                genre['icon'],
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Page indicator
                      //const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(totalPages, (index) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  currentPage == index
                                      ? Colors.orange
                                      : Colors.orange.withAlpha(76),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _genreItem(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Navigate to genre-specific book list
        Get.toNamed(
          RouteNames.genreBooks,
          arguments: {'genre': title, 'icon': icon},
        );
        debugPrint('Selected genre: $title');
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
          SizedBox(
            width: 60,
           // height: 25, // Fixed width
            child: Text(
              title,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeCategories() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to genre screen with "Kids" genre
              Get.toNamed(
                RouteNames.genreBooks,
                arguments: {'genre': 'Kids', 'icon': Icons.child_care},
              );
            },
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
            onPressed: () {
              // Navigate to genre screen with "Teens" genre
              Get.toNamed(
                RouteNames.genreBooks,
                arguments: {'genre': 'Teens', 'icon': Icons.school},
              );
            },
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
    // If there are no recent books, return an empty container (hidden section)
    if (_recentBooks.isEmpty) {
      return Container();
    }
    // Otherwise, show the section with books
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
          child:
              _recentBooks.isEmpty
                  ? const Center(child: Text('No recent books found'))
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recentBooks.length,
                    itemBuilder: (context, index) {
                      final book = _recentBooks[index];
                      // Set the width to match the grid items (screen width / 3 - spacing)
                      final itemWidth =
                          (MediaQuery.of(context).size.width - 32 - 20) / 3;

                      return GestureDetector(
                        onTap: () async {
                          // Navigate to book details
                          await Get.toNamed(
                            RouteNames.bookDescription,
                            arguments: book,
                          )!.then((_) {
                            // This will run after returning from BookDescriptionScreen
                            _fetchBooks(); // Refresh books after returning
                          });

                          debugPrint('Selected book: ${book.bookName}');
                        },
                        child: Container(
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
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  child:
                                      book.coverUrl != null
                                          ? Image.network(
                                            book.coverUrl!,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.topCenter,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              debugPrint(
                                                'Error loading image: $error',
                                              );
                                              return Container(
                                                color: Colors.grey,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 30,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                          : Container(
                                            color: Colors.grey[300],
                                            child: Center(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
          ],
        ),
        const SizedBox(height: 10),
        // Grid view for Top Explored Books with 3 columns
        _topBooks.isEmpty
            ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('No top books found'),
              ),
            )
            : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio:
                    1 / 1.5, // Set aspect ratio to 1:1.5 (width:height)
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _topBooks.length,
              itemBuilder: (context, index) {
                final book = _topBooks[index];
                return GestureDetector(
                  onTap: () {
                    Get.toNamed(RouteNames.bookDescription, arguments: book)!
                        .then((_) {
                          // This will run after returning from BookDescriptionScreen
                          _fetchBooks();
                        });

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
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                            child:
                                book.coverUrl != null
                                    ? Image.network(
                                      book.coverUrl!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        debugPrint(
                                          'Error loading image: $error',
                                        );
                                        return Container(
                                          color: Colors.grey[300],
                                          child: Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 30,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                    : Container(
                                      color: Colors.grey[300],
                                      child: Center(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
