import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<String> saveOrShareXlsx({
  required Uint8List bytes,
  required String fileName,
}) async {
  final dir = await getApplicationDocumentsDirectory();
  final filePath = '${dir.path}/$fileName';

  final file = File(filePath);
  await file.writeAsBytes(bytes);

  await Share.shareXFiles(
    [XFile(filePath)],
    subject: 'Student Grades Export',
    text: 'Student grades exported from Grade Calculator',
  );

  return filePath;
}

