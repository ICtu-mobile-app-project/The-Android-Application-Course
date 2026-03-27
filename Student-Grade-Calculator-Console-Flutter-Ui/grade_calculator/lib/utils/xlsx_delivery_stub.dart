import 'dart:typed_data';

Future<String> saveOrShareXlsx({
  required Uint8List bytes,
  required String fileName,
}) {
  throw UnsupportedError('XLSX export is not supported on this platform.');
}

