import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileSaver {
  static Future<void> save(Uint8List bytes, String fileName, {String mimeType = 'application/octet-stream'}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType, name: fileName)],
      subject: fileName,
      // Required on iPad, ignored elsewhere.
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
    );
  }
}
