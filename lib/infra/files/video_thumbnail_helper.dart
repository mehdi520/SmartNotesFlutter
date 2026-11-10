/// Makes a small JPEG preview frame for a video (Android / iOS).
/// On web there is no thumbnail support, so it returns null and the tile shows an icon.
library;

export 'video_thumbnail_io.dart' if (dart.library.js_interop) 'video_thumbnail_web.dart';

const List<String> videoExtensions = ['mp4', 'mov', 'm4v', 'avi', 'mkv', 'webm', '3gp'];

bool isVideoFileName(String name) {
  final dot = name.lastIndexOf('.');
  return dot >= 0 && videoExtensions.contains(name.substring(dot + 1).toLowerCase());
}
