import 'dart:typed_data';

/// Stub implementation for mobile platforms
Future<void> copyToClipboard(String text) async {
  // This will never be called on mobile as kIsWeb check prevents it
  throw UnsupportedError('Clipboard not supported on mobile');
}

void downloadFile(Uint8List bytes, String filename) {
  // This will never be called on mobile as kIsWeb check prevents it
  throw UnsupportedError('Browser download not supported on mobile');
}
