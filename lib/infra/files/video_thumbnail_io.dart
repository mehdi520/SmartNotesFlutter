import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailHelper {
  static bool get isSupported => Platform.isAndroid || Platform.isIOS;

  /// Returns a JPEG frame (about [maxWidth] px wide) from the start of the video, or null.
  static Future<Uint8List?> fromBytes(Uint8List video, String fileName, {int maxWidth = 360}) async {
    if (!isSupported) return null;
    File? temp;
    try {
      final dir = await getTemporaryDirectory();
      final ext = fileName.contains('.') ? fileName.split('.').last : 'mp4';
      temp = File('${dir.path}/thumb_${DateTime.now().microsecondsSinceEpoch}.$ext');
      await temp.writeAsBytes(video, flush: true);
      return await VideoThumbnail.thumbnailData(
        video: temp.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: maxWidth,
        quality: 75,
        timeMs: 500,
      );
    } catch (e) {
      debugPrint('Video thumbnail failed for $fileName: $e');
      return null;
    } finally {
      try {
        await temp?.delete();
      } catch (_) {}
    }
  }
}
