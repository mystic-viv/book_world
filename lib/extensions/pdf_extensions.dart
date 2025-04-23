import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

extension PdfPageChangedDetailsExtension on PdfPageChangedDetails {
  int get totalPages {
    // Since we don't have direct access to document or pageCount,
    // we'll need to use a different approach
    
    // Option 1: If you have access to the total pages from the controller
    // This would be set elsewhere in your code
    return 0; // This will be overridden by the controller's value
    
    // Option 2: Return the current page as a fallback
    // return newPageNumber;
  }
}