import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_world/controllers/pdf_controller.dart';
import 'package:book_world/widgets/pdf_viewer/bookmark_dialog.dart';

class PDFAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String bookTitle;
  final PDFController controller;
  
  const PDFAppBar({
    Key? key,
    required this.bookTitle,
    required this.controller,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Hide app bar in fullscreen mode
      if (controller.isFullScreen.value) {
        return AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
        );
      }
      
      return AppBar(
        title: Text(
          bookTitle,
          style: const TextStyle(
            color: Colors.orange,
            fontFamily: 'Sanchez',
            fontWeight: FontWeight.bold,
          ),
          // Add overflow handling for long titles
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Text selection toggle button
          Obx(() => IconButton(
            icon: Icon(
              Icons.text_fields,
              color: controller.enableTextSelection.value
                  ? Colors.orange
                  : Colors.grey,
            ),
            onPressed: controller.toggleTextSelection,
            tooltip: 'Toggle text selection',
          )),
          
          // Bookmark button
          Obx(() => IconButton(
            icon: Icon(
              controller.isBookmarked.value
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: Colors.orange,
            ),
            onPressed: () => controller.toggleBookmark(),
          )),
          
          // Bookmarks list
          IconButton(
            icon: const Icon(Icons.bookmarks, color: Colors.orange),
            onPressed: () => Get.dialog(
              BookmarkDialog(controller: controller),
            ),
          ),
          
          // Fullscreen toggle
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.orange),
            onPressed: () => controller.toggleFullScreen(),
          ),
        ],
      );
    });
  }  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
