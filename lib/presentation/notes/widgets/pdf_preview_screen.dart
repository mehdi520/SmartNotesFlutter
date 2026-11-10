import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../infra/core/core_exports.dart';

/// Full-screen PDF viewer (scroll, pinch to zoom, print, share) for an attachment.
class PdfPreviewScreen extends StatefulWidget {
  final String fileName;
  final Future<Uint8List?> Function() load;
  final Future<void> Function(Uint8List bytes)? onDownload;

  const PdfPreviewScreen({super.key, required this.fileName, required this.load, this.onDownload});

  static Future<void> open(
    BuildContext context, {
    required String fileName,
    required Future<Uint8List?> Function() load,
    Future<void> Function(Uint8List bytes)? onDownload,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PdfPreviewScreen(fileName: fileName, load: load, onDownload: onDownload),
      ),
    );
  }

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late final Future<Uint8List?> _bytes = widget.load();

  @override
  Widget build(BuildContext context) {
    final fileName = widget.fileName;
    final onDownload = widget.onDownload;
    return FutureBuilder<Uint8List?>(
      future: _bytes,
      builder: (context, snap) {
        final bytes = snap.data;
        return Scaffold(
          backgroundColor: const Color(0xFFF1F1F4),
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16)),
            actions: [
              if (bytes != null && onDownload != null)
                IconButton(
                  tooltip: 'Download',
                  icon: const Icon(Icons.download_outlined),
                  onPressed: () => onDownload(bytes),
                ),
            ],
          ),
          body: switch (snap.connectionState) {
            ConnectionState.done when bytes != null => PdfPreview(
              build: (_) async => bytes,
              pdfFileName: fileName,
              useActions: true,
              allowPrinting: true,
              allowSharing: true,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              maxPageWidth: 900,
              loadingWidget: const CircularProgressIndicator(),
              onError:
                  (context, error) => const _Message(
                    icon: Icons.broken_image_outlined,
                    text: 'This PDF could not be displayed. Try downloading it instead.',
                  ),
            ),
            ConnectionState.done => const _Message(icon: Icons.cloud_off_outlined, text: 'Could not load this PDF.'),
            _ => const Center(child: CircularProgressIndicator()),
          },
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Message({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade500),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    ),
  );
}
