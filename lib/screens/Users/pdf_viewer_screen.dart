import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:book_world/controllers/pdf_controller.dart';

class PDFViewerScreen extends StatelessWidget {
  final String bookTitle;
  
  const PDFViewerScreen({
    Key? key,
    required this.bookTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PDFController controller = Get.find<PDFController>();
    
    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          appBar: AppBar(
            title: Text(bookTitle),
            backgroundColor: Colors.orange,
          ),
          body: const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          ),
        );
      }
      
      if (controller.isError.value) {
        return Scaffold(
          appBar: AppBar(
            title: Text(bookTitle),
            backgroundColor: Colors.orange,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${controller.errorMessage.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadPdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        );
      }
      
      return Scaffold(
        appBar: controller.isFullScreen.value
            ? null
            : AppBar(
                title: Text(bookTitle),
                backgroundColor: Colors.orange,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.bookmark),
                    onPressed: () => _showBookmarksDialog(context, controller),
                    color: controller.isBookmarked.value ? Colors.yellow : Colors.white,
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen),
                    onPressed: controller.toggleFullScreen,
                  ),
                ],
              ),
        body: Stack(
          children: [
            SfPdfViewer.file(
              File(controller.localPdfPath.value),
              controller: controller.pdfViewerController,
              key: controller.pdfViewerKey,
              onPageChanged: (PdfPageChangedDetails details) {
                // Update current page (subtract 1 if your page indexing starts at 0)
                controller.currentPage.value = details.newPageNumber - 1;
                // Get total pages from the controller instead of the details
                // The controller has access to the document and can provide the total page count
                if (controller.pdfViewerController.pageCount > 0) {
                  controller.totalPages.value = controller.pdfViewerController.pageCount;
                }
              },
            ),
            if (controller.isFullScreen.value)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      Text(
                        bookTitle,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.bookmark,
                              color: controller.isBookmarked.value ? Colors.yellow : Colors.white,
                            ),
                            onPressed: () => _showBookmarksDialog(context, controller),
                          ),
                          IconButton(
                            icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                            onPressed: controller.toggleFullScreen,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page ${controller.currentPage.value + 1} of ${controller.totalPages.value}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: controller.previousPage,
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          onPressed: controller.nextPage,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
  
  void _showBookmarksDialog(BuildContext context, PDFController controller) {
    if (controller.isBookmarked.value) {
      // If current page is already bookmarked, show options
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Bookmark Options'),
          content: const Text('What would you like to do?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.toggleBookmark();
              },
              child: const Text('Remove Bookmark', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showAllBookmarksDialog(context, controller);
              },
              child: const Text('View All Bookmarks', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      // If current page is not bookmarked, show add bookmark dialog
      final TextEditingController textController = TextEditingController(
        text: 'Page ${controller.currentPage.value + 1}',
      );
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Bookmark'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'Bookmark Title',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.addBookmarkWithTitle(textController.text);
              },
              child: const Text('Add', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showAllBookmarksDialog(context, controller);
              },
              child: const Text('View All', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }
  
  void _showAllBookmarksDialog(BuildContext context, PDFController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Bookmarks'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            if (controller.bookmarks.isEmpty) {
              return const Center(
                child: Text('No bookmarks yet'),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              itemCount: controller.bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = controller.bookmarks[index];
                return ListTile(
                  title: Text(bookmark.title),
                  subtitle: Text('Page ${bookmark.pageNumber + 1}'),
                  onTap: () {
                    Navigator.pop(context);
                    controller.jumpToBookmark(bookmark);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      controller.deleteBookmark(bookmark.id!);
                      // If no bookmarks left, close dialog
                      if (controller.bookmarks.isEmpty) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}