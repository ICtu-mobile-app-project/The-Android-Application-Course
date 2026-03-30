import 'dart:typed_data';
import 'dart:html' as html;

Future<String> saveOrShareXlsx({
  required Uint8List bytes,
  required String fileName,
}) async {
  final blob = html.Blob(
    [bytes],
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );

  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..style.display = 'none';

  final body = html.document.body;
  if (body == null) {
    html.Url.revokeObjectUrl(url);
    throw StateError('Cannot export on web because document.body is unavailable.');
  }

  body.children.add(anchor);
  anchor.click();
  // Keep the object URL alive briefly so Chrome can start the download.
  await Future<void>.delayed(const Duration(milliseconds: 300));
  anchor.remove();
  html.Url.revokeObjectUrl(url);

  return fileName;
}

