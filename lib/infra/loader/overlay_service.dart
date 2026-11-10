import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:note_book/infra/loader/loading_overly_widget.dart';

class OverlayService {
  OverlayEntry? _overlayEntry;

  void showLoadingOverlay(BuildContext context, {ValueListenable<double?>? progress}) {
    final overlay = Overlay.of(context);
    if (_overlayEntry != null) return; // Overlay is already shown

    _overlayEntry = OverlayEntry(builder: (context) => Positioned.fill(child: LoadingOverlay(progress: progress)));

    overlay.insert(_overlayEntry!);
  }

  void hideLoadingOverlay() {
    if (_overlayEntry == null) return; // No overlay to remove

    _overlayEntry!.remove();
    _overlayEntry = null;
  }
}
