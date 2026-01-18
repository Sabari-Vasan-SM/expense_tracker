import 'dart:html' as html;
import 'dart:typed_data';

/// Web-specific implementation
Future<void> copyToClipboard(String text) async {
  await html.window.navigator.clipboard!.writeText(text);
}

void downloadFile(Uint8List bytes, String filename) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
