/// Save a file the user can keep:
/// - Web: browser download.
/// - Android / iOS / desktop: writes to a temp file and opens the share sheet
///   (user can "Save to Files", Drive, WhatsApp, email, ...).
library;

export 'file_saver_io.dart' if (dart.library.js_interop) 'file_saver_web.dart';
