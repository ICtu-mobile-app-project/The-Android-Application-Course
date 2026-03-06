// ignore_for_file: avoid_print
// Console app — print() is the intended output mechanism here.
import 'dart:io';
import 'dart:convert';

// ── Student model (standalone, no Flutter dependency) ──────────────────────
class Student {
  final String name;
  final int? score;

  const Student({required this.name, this.score});

  String get grade {
    if (score == null) return '–';
    if (score! >= 90) return 'A';
    if (score! >= 80) return 'B';
    if (score! >= 70) return 'C';
    if (score! >= 60) return 'D';
    return 'F';
  }

  @override
  String toString() {
    if (score == null) return 'No score for $name';
    return '$name scored $score → Grade $grade';
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────
const String _divider = '─────────────────────────────────────────────────────';

void _printHeader(String title) {
  print('');
  print(_divider);
  print('  $title');
  print(_divider);
}

void _printMenu() {
  _printHeader('📚  STUDENT GRADE CALCULATOR  (Console Edition)');
  print('  1 │ Add a student');
  print('  2 │ View all students');
  print('  3 │ Search student by name');
  print('  4 │ Show class statistics');
  print('  5 │ Clear all students');
  print('  6 │ Exit');
  print(_divider);
}

// ── Input helpers ──────────────────────────────────────────────────────────
String _readLine() {
  // Read raw bytes then decode, avoids Windows UTF-8 / codepage issues
  final bytes = <int>[];
  while (true) {
    final byte = stdin.readByteSync();
    if (byte == -1 || byte == 10) break; // EOF or \n
    if (byte == 13) continue;            // skip \r
    bytes.add(byte);
  }
  return utf8.decode(bytes, allowMalformed: true).trim();
}

String _prompt(String message) {
  stdout.write('  $message');
  return _readLine();
}

int? _promptInt(String message) {
  final raw = _prompt(message);
  if (raw.isEmpty) return null;
  return int.tryParse(raw);
}

// ── Actions ────────────────────────────────────────────────────────────────
Student? _addStudent() {
  print('');
  print('  ── Add New Student ──');
  final name = _prompt('Enter student name : ');
  if (name.isEmpty) {
    print('  ⚠  Name cannot be empty.');
    return null;
  }

  final scoreUnknown = _prompt('Is the score unknown? (y/N) : ').toLowerCase();
  int? score;

  if (scoreUnknown != 'y') {
    score = _promptInt('Enter score (0–100)  : ');
    if (score == null || score < 0 || score > 100) {
      print('  ⚠  Invalid score. Please enter a number between 0 and 100.');
      return null;
    }
  }

  final student = Student(name: name, score: score);
  print('  ✅ Added: $student');
  return student;
}

void _viewAll(List<Student> students) {
  if (students.isEmpty) {
    print('\n  📭 No students added yet.\n');
    return;
  }

  _printHeader('Student List  (${students.length} student${students.length == 1 ? '' : 's'})');

  // Table header
  print('  ${'#'.padRight(4)}'
      '${'Name'.padRight(20)}'
      '${'Score'.padRight(10)}'
      'Grade');
  print('  ${'─' * 4}${'─' * 20}${'─' * 10}${'─' * 5}');

  for (var i = 0; i < students.length; i++) {
    final s = students[i];
    print('  ${(i + 1).toString().padRight(4)}'
        '${s.name.padRight(20)}'
        '${(s.score?.toString() ?? 'N/A').padRight(10)}'
        '${s.grade}');
  }
  print('');
}

void _searchStudent(List<Student> students) {
  if (students.isEmpty) {
    print('\n  📭 No students to search.\n');
    return;
  }

  final query = _prompt('Enter name to search : ').toLowerCase();
  final matches =
      students.where((s) => s.name.toLowerCase().contains(query)).toList();

  if (matches.isEmpty) {
    print('  🔍 No students found matching "$query".');
  } else {
    print('  🔍 Found ${matches.length} result${matches.length == 1 ? '' : 's'}:');
    for (final s in matches) {
      print('     • $s');
    }
  }
  print('');
}

void _showStatistics(List<Student> students) {
  final scored = students.where((s) => s.score != null).toList();
  if (scored.isEmpty) {
    print('\n  📊 No scored students to compute statistics.\n');
    return;
  }

  final scores = scored.map((s) => s.score!).toList()..sort();
  final total = scores.reduce((a, b) => a + b);
  final average = total / scores.length;
  final highest = scores.last;
  final lowest = scores.first;

  // Grade distribution
  final dist = <String, int>{'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0};
  for (final s in scored) {
    dist[s.grade] = (dist[s.grade] ?? 0) + 1;
  }

  _printHeader('Class Statistics');
  print('  Total students  : ${students.length}');
  print('  Scored students : ${scored.length}');
  print('  Highest score   : $highest');
  print('  Lowest score    : $lowest');
  print('  Class average   : ${average.toStringAsFixed(1)}');
  print('');
  print('  Grade Distribution:');
  for (final entry in dist.entries) {
    final bar = '█' * entry.value;
    print('    ${entry.key} │ $bar ${entry.value}');
  }
  print('');
}

// ── Main loop ──────────────────────────────────────────────────────────────
void main() {
  final List<Student> students = [];

  while (true) {
    _printMenu();
    final choice = _prompt('Choose an option (1-6) : ');

    switch (choice) {
      case '1':
        final student = _addStudent();
        if (student != null) students.add(student);
        break;
      case '2':
        _viewAll(students);
        break;
      case '3':
        _searchStudent(students);
        break;
      case '4':
        _showStatistics(students);
        break;
      case '5':
        if (students.isEmpty) {
          print('\n  📭 Nothing to clear.\n');
        } else {
          final confirm = _prompt('Clear all ${students.length} students? (y/N) : ');
          if (confirm.toLowerCase() == 'y') {
            students.clear();
            print('  🗑  All students cleared.\n');
          }
        }
        break;
      case '6':
        print('\n  👋 Goodbye!\n');
        return;
      default:
        print('\n  ⚠  Invalid option. Please enter 1–6.\n');
    }
  }
}

