import 'dart:typed_data';

import 'xlsx_delivery_stub.dart'
    if (dart.library.io) 'xlsx_delivery_io.dart'
    if (dart.library.html) 'xlsx_delivery_web.dart' as impl;

/// Saves or shares an XLSX export depending on platform capabilities.
Future<String> saveOrShareXlsx({
  required Uint8List bytes,
  required String fileName,
}) {
  return impl.saveOrShareXlsx(bytes: bytes, fileName: fileName);
}

