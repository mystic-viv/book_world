import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:book_world/models/pdf_bookmark_model.dart';
import 'package:book_world/services/pdf_service.dart';
import 'package:book_world/services/storage_service.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class PDFController extends GetxController {
  final String bookId;
  final String? pdfUrl;
  
  PDFController({required this.bookId, this.pdfUrl});
  
  // Services
  final PDFService _pdfService = PDFService();
  
  // PDF Viewer
  final PdfViewerController pdfViewerController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
  
  // Observables
  final RxBool isLoading = true.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString localPdfPath = ''.obs;
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxBool isFullScreen = false.obs;
  final RxBool isBookmarked = false.obs;
  final RxList<PDFBookmark> bookmarks = <PDFBookmark>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadPdf();
  }
  
  Future<void> loadPdf() async {
    try {
      isLoading.value = true;
      isError.value = false;
      
      // Get PDF URL if not provided
      final String? finalPdfUrl = await _pdfService.getPdfUrl(bookId, pdfUrl);
      if (finalPdfUrl == null) {
        throw Exception('PDF URL not found');
      }
      
      // Download and cache PDF
      final String? path = await _pdfService.downloadAndCachePdf(bookId, finalPdfUrl);
      if (path == null) {
        throw Exception('Failed to download PDF');
      }
      
      localPdfPath.value = path;
      
      // Load bookmarks from database
      await loadBookmarks();
      
      // Load reading progress from database
      await loadReadingProgress();
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      isError.value = true;
      errorMessage.value = e.toString();
      debugPrint('Error loading PDF: $e');
    }
  }
  
  Future<void> loadBookmarks() async {
    try {
      final dbBookmarks = await _pdfService.getBookmarks(bookId);
      bookmarks.value = dbBookmarks;
      checkIfPageIsBookmarked();
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      // Fall back to local storage
      bookmarks.value = StorageServices.getBookmarks(bookId);
    }
  }
  
  Future<void> loadReadingProgress() async {
    try {
      final progress = await _pdfService.getReadingProgress(bookId);
      if (progress != null) {
        // Jump to last read page after PDF is loaded
        Future.delayed(const Duration(milliseconds: 500), () {
          if (pdfViewerController.pageCount >= progress.lastReadPage) {
            pdfViewerController.jumpToPage(progress.lastReadPage);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading reading progress: $e');
      // Fall back to local storage
      final localProgress = StorageServices.getReadingProgress(bookId);
      if (localProgress != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (pdfViewerController.pageCount >= localProgress.lastReadPage) {
            pdfViewerController.jumpToPage(localProgress.lastReadPage);
          }
        });
      }
    }
  }
  
  Future<void> saveReadingProgress() async {
    final progress = PDFReadingProgress(
      bookId: bookId,
      lastReadPage: currentPage.value,
      lastReadTime: DateTime.now(),
    );
    
    try {
      await _pdfService.saveReadingProgress(progress);
    } catch (e) {
      debugPrint('Error saving reading progress: $e');
    }
  }
  
  void onPageChanged(int page) {
    currentPage.value = page;
    
    // Check if current page is bookmarked
    checkIfPageIsBookmarked();
    
    // Save reading progress
    saveReadingProgress();
  }
  
  void checkIfPageIsBookmarked() {
    isBookmarked.value = bookmarks.any((b) => b.pageNumber == currentPage.value);
  }
  
  Future<void> toggleBookmark() async {
    if (isBookmarked.value) {
      // Remove bookmark
      final bookmarkToRemove = bookmarks.firstWhere(
        (b) => b.pageNumber == currentPage.value
      );
      await _pdfService.deleteBookmark(bookmarkToRemove.id ?? '');
      bookmarks.removeWhere((b) => b.id == bookmarkToRemove.id);
    } else {
      // Add bookmark
      final newBookmark = PDFBookmark(
        id: const Uuid().v4(),
        bookId: bookId,
        pageNumber: currentPage.value,
        title: 'Page ${currentPage.value + 1}',
        createdAt: DateTime.now(),
      );
      
      final savedBookmark = await _pdfService.saveBookmark(newBookmark);
      bookmarks.add(savedBookmark);
    }
    
    isBookmarked.value = !isBookmarked.value;
  }
  
  Future<void> addBookmarkWithTitle(String title) async {
    final newBookmark = PDFBookmark(
      id: const Uuid().v4(),
      bookId: bookId,
      pageNumber: currentPage.value,
      title: title.isEmpty ? 'Page ${currentPage.value + 1}' : title,
      createdAt: DateTime.now(),
    );
    
    final savedBookmark = await _pdfService.saveBookmark(newBookmark);
    bookmarks.add(savedBookmark);
    isBookmarked.value = true;
  }
  
  void jumpToBookmark(PDFBookmark bookmark) {
    pdfViewerController.jumpToPage(bookmark.pageNumber);
  }
  
  Future<void> deleteBookmark(String bookmarkId) async {
    await _pdfService.deleteBookmark(bookmarkId);
    bookmarks.removeWhere((b) => b.id == bookmarkId);
    checkIfPageIsBookmarked();
  }
  
  void toggleFullScreen() {
    isFullScreen.value = !isFullScreen.value;
  }
  
  void nextPage() {
    if (currentPage.value < totalPages.value - 1) {
      pdfViewerController.nextPage();
    }
  }
  
  void previousPage() {
    if (currentPage.value > 0) {
      pdfViewerController.previousPage();
    }
  }
  
  @override
  void onClose() {
    // Save reading progress when closing
    saveReadingProgress();
    super.onClose();
  }
}
