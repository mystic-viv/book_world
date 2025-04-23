import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:book_world/controllers/pdf_controller.dart';
import 'package:book_world/widgets/pdf_viewer/bookmark_dialog.dart';
import 'package:book_world/widgets/pdf_viewer/pdf_app_bar.dart';
import 'package:book_world/widgets/pdf_viewer/pdf_bottom_bar.dart';

class PDFViewerScreen extends StatelessWidget {
  final String bookTitle;

  const PDFViewerScreen({super.key, required this.bookTitle});

  @override
  Widget build(BuildContext context) {
    final PDFController controller = Get.find<PDFController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          appBar: PDFAppBar(bookTitle: bookTitle, controller: controller),
          body: const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          ),
        );
      }

      if (controller.isError.value) {
        return Scaffold(
          appBar: PDFAppBar(bookTitle: bookTitle, controller: controller),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
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
        appBar:
            controller.isFullScreen.value
                ? null
                : PDFAppBar(bookTitle: bookTitle, controller: controller),
        body: Stack(
          children: [
            SfPdfViewer.file(
              File(controller.localPdfPath.value),
              controller: controller.pdfViewerController,
              key: controller.pdfViewerKey,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                // Initialize total pages when document is first loaded
                controller.totalPages.value = details.document.pages.count;
              },
              onPageChanged: (PdfPageChangedDetails details) {
                controller.currentPage.value = details.newPageNumber - 1;
                if (controller.pdfViewerController.pageCount > 0) {
                  controller.totalPages.value =
                      controller.pdfViewerController.pageCount;
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bookTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.bookmark,
                              color:
                                  controller.isBookmarked.value
                                      ? Colors.yellow
                                      : Colors.white,
                            ),
                            onPressed:
                                () => Get.dialog(
                                  BookmarkDialog(controller: controller),
                                ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.fullscreen_exit,
                              color: Colors.white,
                            ),
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
              child: PDFBottomBar(controller: controller),
            ),
          ],
        ),
      );
    });
  }
}
