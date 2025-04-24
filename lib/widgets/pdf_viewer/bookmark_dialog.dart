import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_world/controllers/pdf_controller.dart';
import 'package:book_world/models/pdf_bookmark_model.dart';

class BookmarkDialog extends StatelessWidget {
  final PDFController controller;

  const BookmarkDialog({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // Make the dialog wider to accommodate longer bookmark titles
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bookmarks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.bookmarks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No bookmarks yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

               // Use a ConstrainedBox to limit the height but allow scrolling
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
                  // Set a minimum width to ensure there's enough space for titles
                  minWidth: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                ),
                child: ListView.builder(
                  itemCount: controller.bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = controller.bookmarks[index];
                    return BookmarkTile(
                      bookmark: bookmark,
                      controller: controller,
                      onEdit: () => _showEditBookmarkDialog(context, bookmark),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showAddBookmarkDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    'Add Bookmark',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBookmarkDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController(
      text: 'Page ${controller.currentPage.value + 1}',
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Bookmark',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: 'Bookmark Title',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.addBookmarkWithTitle(textController.text);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditBookmarkDialog(BuildContext context, PDFBookmark bookmark) {
    final TextEditingController textController = TextEditingController(
      text: bookmark.title,
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Bookmark',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: 'Bookmark Title',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.updateBookmarkTitle(bookmark.id!, textController.text);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookmarkTile extends StatelessWidget {
  final PDFBookmark bookmark;
  final PDFController controller;
  final VoidCallback onEdit;

  const BookmarkTile({
    Key? key,
    required this.bookmark,
    required this.controller,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(bookmark.title),
      subtitle: Text('Page ${bookmark.pageNumber + 1}'),
      leading: const Icon(Icons.bookmark, color: Colors.orange),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add edit button
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
            tooltip: 'Edit bookmark',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => controller.deleteBookmark(bookmark.id ?? ''),
            tooltip: 'Delete bookmark',
          ),
        ],
      ),
      onTap: () {
        controller.jumpToBookmark(bookmark);
        Get.back();
      },
    );
  }
}