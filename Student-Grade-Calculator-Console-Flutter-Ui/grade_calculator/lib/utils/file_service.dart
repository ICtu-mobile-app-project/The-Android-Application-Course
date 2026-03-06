import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/student.dart';
import 'grade_calculator.dart';

// ── Result type returned by the import function ──────────────────────────────

class ImportResult {
  /// Students successfully parsed from the Excel file.
  final List<Student> students;

  /// Human-readable summary of what was found in the file.
  final String summary;

  const ImportResult({required this.students, required this.summary});
}

// ── Excel column-header aliases (case-insensitive) ───────────────────────────

const _nameAliases  = ['name', 'student', 'student name', 'full name', 'fullname'];
const _scoreAliases = ['score', 'marks', 'mark', 'result', 'points'];
const _gradeAliases = ['grade', 'letter grade', 'letter', 'rating'];

// ── Internal helpers ─────────────────────────────────────────────────────────

/// Normalises a cell value to a trimmed String (null → '').
String _cellText(dynamic v) => v?.toString().trim() ?? '';

/// Checks if a string looks like a header token.
bool _matchesAlias(String cell, List<String> aliases) =>
    aliases.contains(cell.toLowerCase());

/// Higher-order function: given a list of header strings returns the index of
/// the first one matching [aliases], or -1 if none found.
int _findColumn(List<String> headers, List<String> aliases) =>
    headers.indexWhere((h) => _matchesAlias(h, aliases));

// ── Public API ───────────────────────────────────────────────────────────────

/// Opens the device's file picker filtered to Excel files (.xlsx only), parses
/// the selected file and returns an [ImportResult].
///
/// This is a higher-order function — the [grader] parameter is a function
/// injected at call-time so the grading logic is decoupled from file parsing:
///   e.g.  importStudentsFromExcel(grader: getGrade)
///   or    importStudentsFromExcel(grader: gradingFunction(curve: 5))
Future<ImportResult?> importStudentsFromExcel({
  required String Function(int) grader,
}) async {
  // ── 1. Open the device storage / Google Drive picker ──────────────────────
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
    allowMultiple: false,
    withData: true, // load bytes directly — works on Android without temp file
  );

  if (result == null || result.files.isEmpty) return null;

  final Uint8List? bytes = result.files.first.bytes;
  if (bytes == null) return null;

  return _parseExcelBytes(bytes: bytes, grader: grader);
}

/// Parses raw Excel bytes into a list of [Student] objects.
///
/// Column detection strategy (in order):
///   1. Look for a header row with recognised column names.
///   2. Fall back to positional: col-0 = name, col-1 = score, col-2 = grade.
///
/// For each row the function:
///   • Always reads the student name.
///   • Reads the score if the column is present (null if missing/blank).
///   • Reads a pre-existing grade if the grade column is present;
///     otherwise derives the grade from the score using [grader].
ImportResult _parseExcelBytes({
  required Uint8List bytes,
  required String Function(int) grader,
}) {
  final excel = Excel.decodeBytes(bytes);

  // Use the first non-empty sheet
  final String sheetName = excel.sheets.keys.firstWhere(
    (s) => excel.sheets[s]!.rows.isNotEmpty,
    orElse: () => excel.sheets.keys.first,
  );
  final sheet = excel.sheets[sheetName]!;
  final rows = sheet.rows;

  if (rows.isEmpty) {
    return const ImportResult(students: [], summary: 'The sheet is empty.');
  }

  // ── Detect header row ──────────────────────────────────────────────────────
  final firstRowText =
      rows.first.map((c) => _cellText(c?.value)).toList();

  final bool hasHeader = firstRowText.any(
    (cell) =>
        _matchesAlias(cell, _nameAliases) ||
        _matchesAlias(cell, _scoreAliases) ||
        _matchesAlias(cell, _gradeAliases),
  );

  int nameCol, scoreCol, gradeCol;
  int dataStart;

  if (hasHeader) {
    nameCol  = _findColumn(firstRowText, _nameAliases);
    scoreCol = _findColumn(firstRowText, _scoreAliases);
    gradeCol = _findColumn(firstRowText, _gradeAliases);
    dataStart = 1;
    // Fall back to positional for any column that wasn't found via header
    if (nameCol  == -1) { nameCol  = 0; }
    if (scoreCol == -1) { scoreCol = (nameCol == 0) ? 1 : 0; }
  } else {
    // Positional fall-back
    nameCol   = 0;
    scoreCol  = 1;
    gradeCol  = 2;
    dataStart = 0;
  }

  // ── Parse data rows using higher-order map ─────────────────────────────────
  final dataRows = rows.skip(dataStart).where(
    // Lambda: skip completely empty rows
    (row) => row.any((c) => _cellText(c?.value).isNotEmpty),
  );

  int withScore = 0, withoutScore = 0, withExistingGrade = 0;

  final students = dataRows.map((row) {
    // Lambda helpers for safe column access
    String cell(int col) =>
        col >= 0 && col < row.length ? _cellText(row[col]?.value) : '';

    final name  = cell(nameCol);
    if (name.isEmpty) return null; // skip rows with no name

    final scoreStr = cell(scoreCol);
    final int? score = int.tryParse(scoreStr);

    // Check if the file already has a grade column
    final existingGrade = gradeCol >= 0 ? cell(gradeCol) : '';
    final bool hasExistingGrade =
        existingGrade.isNotEmpty && RegExp(r'^[A-Fa-f–-]$').hasMatch(existingGrade);

    if (hasExistingGrade) { withExistingGrade++; }
    if (score != null) { withScore++; } else { withoutScore++; }

    return Student(name: name, score: score);
  }).whereType<Student>().toList();

  // ── Build summary ──────────────────────────────────────────────────────────
  final buffer = StringBuffer()
    ..write('Imported ${students.length} student(s). ')
    ..write('$withScore with score(s), ')
    ..write('$withoutScore without score(s)');
  if (withExistingGrade > 0) {
    buffer.write(', $withExistingGrade already had a grade (grades recalculated from scores)');
  }
  buffer.write('.');

  return ImportResult(students: students, summary: buffer.toString());
}

// ── Export ────────────────────────────────────────────────────────────────────

/// Builds an Excel file from [students], saves it to the device and opens
/// the share-sheet so the user can save / send it anywhere.
///
/// [rowBuilder] is a higher-order function injected by the caller that
/// converts a [Student] into the list of cell values for that row:
///   e.g.  rowBuilder: (s) => [s.name, s.score?.toString() ?? 'N/A', getGrade(s.score!)]
Future<String> exportStudentsToExcel({
  required List<Student> students,
  required List<dynamic> Function(Student) rowBuilder,
}) async {
  final excel = Excel.createExcel();
  final sheet = excel['Students'];

  // Remove the default "Sheet1" that Excel creates automatically
  excel.delete('Sheet1');

  // ── Header row ────────────────────────────────────────────────────────────
  final headers = ['#', 'Student Name', 'Score', 'Grade'];
  for (int i = 0; i < headers.length; i++) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
    );
    cell.value = TextCellValue(headers[i]);
    cell.cellStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#1A73E8'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );
  }

  // ── Data rows — higher-order map + lambda enumerate ───────────────────────
  students.asMap().forEach((index, student) {
    // rowBuilder lambda converts Student → list of values
    final rowData = rowBuilder(student);
    // Prepend the row number
    final fullRow = [index + 1, ...rowData];

    for (int col = 0; col < fullRow.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: index + 1),
      );
      final value = fullRow[col];
      cell.value = value is int
          ? IntCellValue(value)
          : TextCellValue(value.toString());

      // Colour-code the grade cell using a lambda
      if (col == fullRow.length - 1 && student.score != null) {
        final grade = getGrade(student.score!);
        final colour = _gradeHex(grade);
        cell.cellStyle = CellStyle(
          fontColorHex: ExcelColor.fromHexString(colour),
          bold: true,
        );
      }
    }
  });

  // Auto-fit column widths (approximate)
  sheet.setColumnWidth(0, 5);
  sheet.setColumnWidth(1, 24);
  sheet.setColumnWidth(2, 10);
  sheet.setColumnWidth(3, 10);

  // ── Save file ─────────────────────────────────────────────────────────────
  final Uint8List fileBytes = Uint8List.fromList(excel.encode()!);

  final dir = await getApplicationDocumentsDirectory();
  final timestamp = DateTime.now()
      .toIso8601String()
      .replaceAll(RegExp(r'[:.T]'), '-')
      .substring(0, 19);
  final filePath = '${dir.path}/grades_$timestamp.xlsx';

  final file = File(filePath);
  await file.writeAsBytes(fileBytes);

  // ── Share sheet (share_plus v10 API) ─────────────────────────────────────
  await Share.shareXFiles(
    [XFile(filePath)],
    subject: 'Student Grades Export',
    text: 'Student grades exported from Grade Calculator',
  );

  return filePath;
}

/// Maps a grade letter to a hex colour for Excel cell styling.
String _gradeHex(String grade) {
  const map = {
    'A': '#2E7D32',
    'B': '#00796B',
    'C': '#F57F17',
    'D': '#E65100',
    'F': '#C62828',
  };
  return map[grade] ?? '#9E9E9E';
}

