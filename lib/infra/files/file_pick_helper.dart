import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note_book/domain/models/note/data_model/picked_file_model.dart';

/// Where an attachment comes from.
enum AttachmentSource { camera, gallery, document, file }

/// Picks files on web, Android and iOS and returns their bytes.
class FilePickHelper {
  /// Max size of one file (must match the API's Uploads:MaxFileSizeMB).
  static const int maxFileBytes = 25 * 1024 * 1024;

  /// Extensions offered by the "Document" option.
  static const List<String> documentExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'csv',
    'ppt',
    'pptx',
    'txt',
    'rtf',
    'odt',
    'ods',
    'odp',
  ];

  static final ImagePicker _imagePicker = ImagePicker();

  /// Returns the picked files (empty if cancelled) and the names that were skipped as too large.
  static Future<({List<PickedFileModel> files, List<String> tooLarge})> pick({
    AttachmentSource source = AttachmentSource.file,
    bool multiple = true,
  }) async {
    switch (source) {
      case AttachmentSource.camera:
        final photo = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85);
        return _fromXFiles(photo == null ? [] : [photo], renameAsPhoto: true);
      case AttachmentSource.gallery:
        final media =
            multiple
                ? await _imagePicker.pickMultipleMedia(imageQuality: 85)
                : [if (await _imagePicker.pickMedia(imageQuality: 85) case final m?) m];
        return _fromXFiles(media);
      case AttachmentSource.document:
        return _pickWithFilePicker(multiple: multiple, type: FileType.custom, allowedExtensions: documentExtensions);
      case AttachmentSource.file:
        return _pickWithFilePicker(multiple: multiple, type: FileType.any);
    }
  }

  static Future<({List<PickedFileModel> files, List<String> tooLarge})> _pickWithFilePicker({
    required bool multiple,
    required FileType type,
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: multiple,
      type: type,
      allowedExtensions: allowedExtensions,
      withData: true,
    );
    if (result == null) return (files: <PickedFileModel>[], tooLarge: <String>[]);

    final files = <PickedFileModel>[];
    final tooLarge = <String>[];
    for (final f in result.files) {
      if (f.size > maxFileBytes) {
        tooLarge.add(f.name);
        continue;
      }
      final bytes = f.bytes ?? await f.xFile.readAsBytes();
      files.add(PickedFileModel(name: f.name, bytes: bytes));
    }
    return (files: files, tooLarge: tooLarge);
  }

  static Future<({List<PickedFileModel> files, List<String> tooLarge})> _fromXFiles(
    List<XFile> picked, {
    bool renameAsPhoto = false,
  }) async {
    final files = <PickedFileModel>[];
    final tooLarge = <String>[];
    for (final x in picked) {
      final name = renameAsPhoto ? _photoName(x.name) : x.name;
      if (await x.length() > maxFileBytes) {
        tooLarge.add(name);
        continue;
      }
      files.add(PickedFileModel(name: name, bytes: await x.readAsBytes()));
    }
    return (files: files, tooLarge: tooLarge);
  }

  /// Camera files get random names (e.g. image_picker_3F2A.jpg); use a readable one instead.
  static String _photoName(String original) {
    final ext = original.contains('.') ? original.split('.').last.toLowerCase() : 'jpg';
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return 'Photo_${n.year}${two(n.month)}${two(n.day)}_${two(n.hour)}${two(n.minute)}${two(n.second)}.$ext';
  }
}
