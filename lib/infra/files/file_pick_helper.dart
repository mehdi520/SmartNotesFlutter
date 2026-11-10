import 'package:file_picker/file_picker.dart';
import 'package:note_book/domain/models/note/data_model/picked_file_model.dart';

/// Picks files on web, Android and iOS and returns their bytes.
class FilePickHelper {
  /// Max size of one file (must match the API's Uploads:MaxFileSizeMB).
  static const int maxFileBytes = 25 * 1024 * 1024;

  /// Returns the picked files (empty if cancelled) and the names that were skipped as too large.
  static Future<({List<PickedFileModel> files, List<String> tooLarge})> pick({bool multiple = true}) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: multiple,
      type: FileType.any,
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
}
