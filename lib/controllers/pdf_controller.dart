import 'dart:async';
import 'package:book_world/utils/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:book_world/models/pdf_bookmark_model.dart';
import 'package:book_world/services/pdf_service.dart';
import 'package:book_world/services/storage_service.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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

  // Text selection properties
  final RxBool enableTextSelection = true.obs;
  final RxString selectedText = ''.obs;
  final RxBool showTextSelectionMenu = false.obs;
  final RxDouble menuPositionX = 0.0.obs;
  final RxDouble menuPositionY = 0.0.obs;

  // Debounce for text selection
  Worker? _textSelectionDebounce;

  @override
  void onInit() {
    super.onInit();

    // Setup debounce for text selection to prevent too many UI updates
    _textSelectionDebounce = debounce(
      selectedText,
      (_) => checkIfPageIsBookmarked(),
      time: const Duration(milliseconds: 300),
    );

    // Load PDF with slight delay to allow UI to render first
    Future.delayed(const Duration(milliseconds: 100), loadPdf);
  }

  Future<void> loadPdf() async {
    isLoading.value = true;
    isError.value = false;
    
    try {
      // Get PDF URL if not provided
      final String? finalPdfUrl = await _pdfService.getPdfUrl(bookId, pdfUrl);
      if (finalPdfUrl == null || finalPdfUrl.isEmpty) {
        throw Exception('PDF URL not found or is empty');
      }
    
      // Print the URL for debugging
      print('Attempting to download PDF from: $finalPdfUrl');
    
      // Check if PDF is already cached
      String? path;
      final cachedPath = StorageServices.getCachedPdfPath(bookId);
      if (cachedPath != null) {
        final cachedFile = File(cachedPath);
        if (await cachedFile.exists() && await cachedFile.length() > 0) {
          print('Using cached PDF file: $cachedPath');
          path = cachedPath;
        } else {
          print('Cached file exists but may be invalid, downloading again');
        }
      }
    
      // If not cached, download it
      if (path == null) {
        try {
          // Use a simpler function for compute that doesn't require the controller
          print('Downloading PDF using compute...');
          path = await compute(_downloadPdf, {
            'bookId': bookId,
            'url': finalPdfUrl,
          });
        
          if (path == null) {
            print('Compute download failed, trying direct download...');
            path = await _downloadPdfDirect(bookId, finalPdfUrl);
          }
        } catch (computeError) {
          // Fallback if compute fails
          print('Compute failed, falling back to direct download: $computeError');
          path = await _downloadPdfDirect(bookId, finalPdfUrl);
        }
      }
    
      if (path == null) {
        throw Exception('Failed to download PDF');
      }
    
      // Verify the file exists and has content
      final pdfFile = File(path);
      if (!await pdfFile.exists()) {
        throw Exception('PDF file does not exist at path: $path');
      }
    
      if (await pdfFile.length() == 0) {
        throw Exception('PDF file is empty at path: $path');
      }
    
      print('PDF successfully downloaded to: $path');
      localPdfPath.value = path;
    
      // Load bookmarks and reading progress in parallel but with a slight delay
      // to prevent UI thread congestion
      await Future.delayed(const Duration(milliseconds: 200));
    
      // Use Future.wait to run these in parallel
      await Future.wait([
        _loadBookmarksAsync(),
        _loadReadingProgressAsync(),
      ]);
    
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      isError.value = true;
      errorMessage.value = e.toString();
      print('Error loading PDF: $e');
    }
  }

  // Static method that can be used with compute
  static Future<String?> _downloadPdf(Map<String, dynamic> params) async {
    final String bookId = params['bookId'];
    final String url = params['url'];
    
    try {
      // Check if URL is valid
      if (url.isEmpty) {
        print('Error: Empty PDF URL provided');
        return null;
      }
    
      // Download the PDF file with timeout
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Connection timeout. Please check your internet connection.');
      });
    
      if (response.statusCode != 200) {
        print('Error: HTTP status ${response.statusCode} when downloading PDF');
        return null;
      }
    
      // Save to local storage
      final appDir = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${appDir.path}/pdfs');
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }
    
      final file = File('${pdfDir.path}/$bookId.pdf');
      await file.writeAsBytes(response.bodyBytes);
    
      // Verify file was created and has content
      if (!await file.exists() || await file.length() == 0) {
        print('Error: Failed to save PDF file or file is empty');
        return null;
      }
    
      return file.path;
    } catch (e) {
      print('Error downloading PDF in isolate: $e');
      return null;
    }
  }

  // Direct download method as fallback
  Future<String?> _downloadPdfDirect(String bookId, String url) async {
    try {
      // Check if URL is valid
      if (url.isEmpty) {
        print('Error: Empty PDF URL provided');
        return null;
      }
    
      // Download the PDF file with timeout
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Connection timeout. Please check your internet connection.');
      });
    
      if (response.statusCode != 200) {
        print('Error: HTTP status ${response.statusCode} when downloading PDF');
        return null;
      }
    
      // Save to local storage
      final appDir = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${appDir.path}/pdfs');
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }
    
      final file = File('${pdfDir.path}/$bookId.pdf');
      await file.writeAsBytes(response.bodyBytes);
    
      // Verify file was created and has content
      if (!await file.exists() || await file.length() == 0) {
        print('Error: Failed to save PDF file or file is empty');
        return null;
      }
    
      return file.path;
    } catch (e) {
      print('Error downloading PDF directly: $e');
      return null;
    }
  }

  // Async wrapper for loadBookmarks to handle errors gracefully
  Future<void> _loadBookmarksAsync() async {
    try {
      await loadBookmarks();
    } catch (e) {
      debugPrint('Error in _loadBookmarksAsync: $e');
      // Don't rethrow - we want to continue even if bookmarks fail
    }
  }

  // Async wrapper for loadReadingProgress to handle errors gracefully
  Future<void> _loadReadingProgressAsync() async {
    try {
      await loadReadingProgress();
    } catch (e) {
      debugPrint('Error in _loadReadingProgressAsync: $e');
      // Don't rethrow - we want to continue even if reading progress fails
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
        // Use a longer delay to ensure PDF is fully loaded
        Future.delayed(const Duration(milliseconds: 800), () {
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
        Future.delayed(const Duration(milliseconds: 800), () {
          if (pdfViewerController.pageCount >= localProgress.lastReadPage) {
            pdfViewerController.jumpToPage(localProgress.lastReadPage);
          }
        });
      }
    }
  }

  // Use a debounced version of saveReadingProgress to prevent too many database writes
  final _saveProgressDebouncer = Debouncer(milliseconds: 2000);

  Future<void> saveReadingProgress() async {
    // Debounce to avoid too many database writes
    _saveProgressDebouncer.run(() async {
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
    });
  }

  void onPageChanged(int page) {
    currentPage.value = page;

    // Check if current page is bookmarked
    checkIfPageIsBookmarked();

    // Save reading progress (debounced)
    saveReadingProgress();

    // Clear any text selection when changing pages
    selectedText.value = '';
    showTextSelectionMenu.value = false;
  }

  void checkIfPageIsBookmarked() {
    isBookmarked.value = bookmarks.any(
      (b) => b.pageNumber == currentPage.value,
    );
  }

  Future<void> toggleBookmark() async {
    if (isBookmarked.value) {
      // Remove bookmark
      final bookmarkToRemove = bookmarks.firstWhere(
        (b) => b.pageNumber == currentPage.value,
      );

      // Update UI immediately
      bookmarks.removeWhere((b) => b.id == bookmarkToRemove.id);
      isBookmarked.value = false;

      // Then perform database operation
      Future.microtask(() async {
        await _pdfService.deleteBookmark(bookmarkToRemove.id ?? '');
      });
    } else {
      // Add bookmark
      final newBookmark = PDFBookmark(
        id: const Uuid().v4(),
        bookId: bookId,
        pageNumber: currentPage.value,
        title: 'Page ${currentPage.value + 1}',
        createdAt: DateTime.now(),
      );

      // Update UI immediately
      bookmarks.add(newBookmark);
      isBookmarked.value = true;

      // Then perform database operation
      Future.microtask(() async {
        final savedBookmark = await _pdfService.saveBookmark(newBookmark);
        // Update with saved version if needed
        final index = bookmarks.indexWhere((b) => b.id == newBookmark.id);
        if (index >= 0) {
          bookmarks[index] = savedBookmark;
        }
      });
    }
  }

  Future<void> addBookmarkWithTitle(String title) async {
    final newBookmark = PDFBookmark(
      id: const Uuid().v4(),
      bookId: bookId,
      pageNumber: currentPage.value,
      title: title.isEmpty ? 'Page ${currentPage.value + 1}' : title,
      createdAt: DateTime.now(),
    );

    // Update UI immediately
    bookmarks.add(newBookmark);
    isBookmarked.value = true;

    // Then perform database operation
    Future.microtask(() async {
      final savedBookmark = await _pdfService.saveBookmark(newBookmark);
      // Update with saved version if needed
      final index = bookmarks.indexWhere((b) => b.id == newBookmark.id);
      if (index >= 0) {
        bookmarks[index] = savedBookmark;
      }
    });
  }

  Future<void> updateBookmarkTitle(String bookmarkId, String newTitle) async {
    // Find the bookmark in the list
    final index = bookmarks.indexWhere((b) => b.id == bookmarkId);
    if (index >= 0) {
      // Create a new bookmark with the updated title
      final updatedBookmark = PDFBookmark(
        id: bookmarkId,
        bookId: bookmarks[index].bookId,
        pageNumber: bookmarks[index].pageNumber,
        title: newTitle,
        createdAt: bookmarks[index].createdAt,
      );
    
      // Update UI immediately
      bookmarks[index] = updatedBookmark;
    
      // Then perform database operation
      Future.microtask(() async {
        try {
          await _pdfService.updateBookmark(updatedBookmark);
        } catch (e) {
          debugPrint('Error updating bookmark: $e');
        }
      });
    }
  }

  void jumpToBookmark(PDFBookmark bookmark) {
    pdfViewerController.jumpToPage(bookmark.pageNumber + 1);
  }

  Future<void> deleteBookmark(String bookmarkId) async {
    // Update UI immediately
    bookmarks.removeWhere((b) => b.id == bookmarkId);
    checkIfPageIsBookmarked();

    // Then perform database operation
    Future.microtask(() async {
      await _pdfService.deleteBookmark(bookmarkId);
    });
  }

  void toggleFullScreen() {
    isFullScreen.value = !isFullScreen.value;

    // When entering fullscreen, make sure to hide any text selection menu
    if (isFullScreen.value) {
      showTextSelectionMenu.value = false;
    }
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

  // Text selection methods with debouncing
  void onTextSelectionChanged(PdfTextSelectionChangedDetails details) {
    if (details.selectedText != null && details.selectedText!.isNotEmpty) {
      selectedText.value = details.selectedText!;

      // Debounce showing the menu to prevent UI jank
      Future.delayed(const Duration(milliseconds: 100), () {
        if (selectedText.value.isNotEmpty) {
          showTextSelectionMenu.value = true;

          // Calculate position for the menu (this is approximate)
          if (details.globalSelectedRegion != null &&
              details.globalSelectedRegion!.isEmpty) {
            final rect = details.globalSelectedRegion!;
            menuPositionX.value = rect.center.dx;
            menuPositionY.value = rect.top - 50; // Position above the selection
          }
        }
      });
    } else {
      selectedText.value = '';
      showTextSelectionMenu.value = false;
    }
  }

  void toggleTextSelection() {
    enableTextSelection.value = !enableTextSelection.value;
    if (!enableTextSelection.value) {
      selectedText.value = '';
      showTextSelectionMenu.value = false;
    }
  }

  void copySelectedText() {
    if (selectedText.value.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: selectedText.value));
      showSnackBar('Copied',
        'Text copied to clipboard',);
      // Clear selection after copying
      pdfViewerController.clearSelection();
      selectedText.value = '';
      showTextSelectionMenu.value = false;
    }
  }

  @override
  void onClose() {
    // Cancel debounce workers
    _textSelectionDebounce?.dispose();
    _saveProgressDebouncer.cancel();

    // Dispose of the PDF viewer controller
    pdfViewerController.dispose();

    // Save reading progress when closing
    final progress = PDFReadingProgress(
      bookId: bookId,
      lastReadPage: currentPage.value,
      lastReadTime: DateTime.now(),
    );

    // Use a synchronous method to ensure it completes before the controller is disposed
    try {
      StorageServices.saveReadingProgress(progress);
      // Try to save to database but don't wait for it
      _pdfService.saveReadingProgress(progress).catchError((e) {
        debugPrint('Error saving final reading progress: $e');
      });
    } catch (e) {
      debugPrint('Error in onClose: $e');
    }

    super.onClose();
  }
}

// Helper class for debouncing
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }
}
