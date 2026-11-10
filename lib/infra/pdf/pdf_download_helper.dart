import 'package:flutter/material.dart';
import 'package:note_book/infra/di/service_locator.dart';
import 'package:note_book/infra/loader/overlay_service.dart';
import 'package:note_book/infra/pdf/note_pdf_service.dart';
import 'package:note_book/infra/utils/toast_utils.dart';

/// Shows the loader while a PDF is built, then a toast with the result.
class PdfDownloadHelper {
  static Future<void> note(BuildContext context, int noteId) =>
      _run(context, () => sl<NotePdfService>().downloadNote(noteId));

  static Future<void> noteBook(BuildContext context, int noteBookId) =>
      _run(context, () => sl<NotePdfService>().downloadNoteBook(noteBookId));

  static Future<void> _run(BuildContext context, Future<String?> Function() task) async {
    final loader = OverlayService();
    loader.showLoadingOverlay(context);
    try {
      final error = await task();
      loader.hideLoadingOverlay();
      if (error != null) {
        ToastUtils.showError(error);
      } else {
        ToastUtils.showSuccess('PDF ready');
      }
    } catch (e) {
      loader.hideLoadingOverlay();
      ToastUtils.showError('PDF failed: $e');
    }
  }
}
