import 'dart:typed_data';

import 'package:note_book/domain/models/note/data_model/note_attachment_model.dart';

/// A file chosen on the device (web, Android or iOS) that is not uploaded yet.
/// Uses bytes (not a path) so it works the same on every platform.
class PickedFileModel {
  final String name;
  final Uint8List bytes;

  const PickedFileModel({required this.name, required this.bytes});

  int get size => bytes.length;

  String get readableSize => formatFileSize(size);

  bool get isImage {
    final n = name.toLowerCase();
    return n.endsWith('.png') || n.endsWith('.jpg') || n.endsWith('.jpeg') ||
        n.endsWith('.gif') || n.endsWith('.webp') || n.endsWith('.bmp');
  }
}
