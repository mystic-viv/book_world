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

              return SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: controller.bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = controller.bookmarks[index];
                    return BookmarkTile(
                      bookmark: bookmark,
                      controller: controller,
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
}

class BookmarkTile extends StatelessWidget {
  final PDFBookmark bookmark;
  final PDFController controller;

  const BookmarkTile({
    Key? key,
    required this.bookmark,
    required this.controller,
  }) : super(key: key);

  @override
    Widget build(BuildContext context) {
    return ListTile(
      title: Text(bookmark.title),
      subtitle: Text('Page ${bookmark.pageNumber + 1}'),
      leading: const Icon(Icons.bookmark, color: Colors.orange),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        /// Deletes a specific bookmark from the PDF viewer
        /// 
        /// This method is triggered when the delete icon is pressed, removing the bookmark
        /// identified by its unique [bookmark.id] from the controller's bookmark list.
        /// 
        /// Parameters:
        /// - [bookmark.id]: The unique identifier of the bookmark to be deleted
        /// 
        /// Calls [PDFController.deleteBookmark] to remove the bookmark from the system
        onPressed: () => controller.deleteBookmark(bookmark.id ?? ''),
      ),
      onTap: () {
        controller.jumpToBookmark(bookmark);
        Get.back();
      },
    );
  }
}