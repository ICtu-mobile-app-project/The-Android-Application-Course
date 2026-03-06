import 'package:flutter/material.dart';
import '../models/student.dart';

// grade calculation data tables used by utilities below.
const _gradeThresholds = <int, String>{
  90: 'A',
  80: 'B',
  70: 'C',
  60: 'D',
};
const _gradeColours = <String, Color>{
  'A': Color(0xFF2E7D32), // green
  'B': Color(0xFF00796B), // teal
  'C': Color(0xFFF57F17), // amber
  'D': Color(0xFFE65100), // deep orange
  'F': Color(0xFFC62828), // red
};

/// Returns the letter grade for a given score (0–100).
/// Uses a small lookup table rather than a cascade of `if` statements.
/// The map is small so the loop is effectively constant‑time.
String getGrade(int score) {
  for (final entry in _gradeThresholds.entries) {
    if (score >= entry.key) return entry.value;
  }
  return 'F';
}

/// Returns the accent colour for a grade.
Color gradeAccentColor(String grade) =>
    _gradeColours[grade] ?? const Color(0xFF9E9E9E);

// ── Higher-order & lambda utility functions ──────────────────────────────────

/// Higher-order function: applies [transform] to every student and returns
/// the resulting list.
/// Example:
///   final named = processStudents(students, (s) => Student(name: s.name.toUpperCase(), score: s.score));
List<Student> processStudents(
  List<Student> students,
  Student Function(Student) transform,
) =>
    students.map(transform).toList();

/// Higher-order function: keeps only the students that satisfy [predicate].
/// Example:
///   final passing = filterStudents(students, (s) => s.score != null && s.score! >= 60);
List<Student> filterStudents(
  List<Student> students,
  bool Function(Student) predicate,
) =>
    students.where(predicate).toList();

/// Higher-order function: reduces a list of students to a single value.
/// Example:
///   final total = reduceStudents(students, 0.0, (acc, s) => acc + (s.score ?? 0));
T reduceStudents<T>(
  List<Student> students,
  T initial,
  T Function(T accumulator, Student student) combine,
) =>
    students.fold(initial, combine);

/// Convenience lambda-style getter: returns a function that grades a score
/// using a custom offset (useful for normalised or curved marking).
///
/// Example:
///   final curvedGrader = gradingFunction(curve: 5);
///   curvedGrader(85) // grades 90 → 'A'
String Function(int) gradingFunction({int curve = 0}) {
  return (int score) => getGrade((score + curve).clamp(0, 100));
}

/// Handy extensions that keep UI code terse.
extension StudentExtensions on Student {
  String get grade => score != null ? getGrade(score!) : '–';
  Color get accent => gradeAccentColor(grade);
}

