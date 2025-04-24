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
          backgroundColor: const Color(0xFFFFE8C6),
          appBar: PDFAppBar(bookTitle: bookTitle, controller: controller),
          body: const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          ),
        );
      }

      if (controller.isError.value) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFE8C6),
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
                const SizedBox(height: 8),
                const Text(
                  'Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
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
        backgroundColor: const Color(0xFFFFE8C6),
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
                controller.onPageChanged(details.newPageNumber - 1);
              },
              enableDocumentLinkAnnotation: false,
              // Enable text selection
              enableTextSelection: controller.enableTextSelection.value,
              onTextSelectionChanged: controller.onTextSelectionChanged,
              // Additional properties for better user experience
              enableDoubleTapZooming: true,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              pageSpacing: 4.0,
              // Limit initial page load
              initialScrollOffset: Offset.zero,
              initialZoomLevel: 1.0,
              // Optimize memory usage
              pageLayoutMode:
                  PdfPageLayoutMode.single, // Load one page at a time
              scrollDirection: PdfScrollDirection.horizontal,
            ),

            // Text selection menu
            Obx(
              () =>
                  controller.showTextSelectionMenu.value
                      ? Positioned(
                        left:
                            controller.menuPositionX.value -
                            75, // Center the menu
                        top: controller.menuPositionY.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                ),
                                onPressed: controller.copySelectedText,
                                tooltip: 'Copy',
                              ),
                              // You can add more options here like highlight, search, etc.
                            ],
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),

            if (controller.isFullScreen.value)
              Positioned(
                top:
                    MediaQuery.of(context).padding.top, // Add safe area padding
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
                      // Limit the width of the title to prevent overflow
                      Expanded(
                        flex: 2, // Give more space to the title
                        child: Text(
                          bookTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      // Wrap buttons in a Row with fixed width
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Add text selection toggle button
                          IconButton(
                            icon: Icon(
                              Icons.text_fields,
                              color: controller.enableTextSelection.value
                                  ? Colors.orange
                                  : Colors.white,
                            ),
                            onPressed: controller.toggleTextSelection,
                            tooltip: 'Toggle text selection',
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.bookmark,
                              color:
                                  controller.isBookmarked.value
                                      ? Colors.orange
                                      : Colors.white,
                            ),
                            onPressed:
                                () => Get.dialog(
                                  BookmarkDialog(controller: controller),
                                ),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.fullscreen_exit,
                              color: Colors.white,
                            ),
                            onPressed: controller.toggleFullScreen,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            padding: EdgeInsets.zero,
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