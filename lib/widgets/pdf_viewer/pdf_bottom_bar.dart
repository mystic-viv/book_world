import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_world/controllers/pdf_controller.dart';

class PDFBottomBar extends StatelessWidget {
  final PDFController controller;
  
  const PDFBottomBar({
    Key? key,
    required this.controller,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Hide bottom bar in fullscreen mode
      if (controller.isFullScreen.value) {
        return const SizedBox.shrink();
      }
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Page indicator
            Obx(() => Text(
              'Page ${controller.currentPage.value + 1} of ${controller.totalPages.value}',
              style: const TextStyle(color: Colors.orange),
            )),
            
            // Navigation buttons
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_double_arrow_left, color: Colors.orange),
                  onPressed: controller.previousPage,
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_double_arrow_right, color: Colors.orange),
                  onPressed: controller.nextPage,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
