import 'package:flutter/material.dart';
import '../models/student.dart';

/// Returns the letter grade for a given score (0–100).
/// Can be used as a first-class function / lambda:
///   e.g.  final grader = getGrade;  grader(85) => 'B'
String getGrade(int score) {
  if (score >= 90) return 'A';
  if (score >= 80) return 'B';
  if (score >= 70) return 'C';
  if (score >= 60) return 'D';
  return 'F';
}

/// Returns the accent colour used for each grade band.
Color gradeAccentColor(String grade) {
  switch (grade) {
    case 'A':
      return const Color(0xFF2E7D32); // green
    case 'B':
      return const Color(0xFF00796B); // teal
    case 'C':
      return const Color(0xFFF57F17); // amber
    case 'D':
      return const Color(0xFFE65100); // deep orange
    case 'F':
      return const Color(0xFFC62828); // red
    default:
      return const Color(0xFF9E9E9E); // grey (no score)
  }
}

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
String Function(int) gradingFunction({int curve = 0}) =>
    (int score) => getGrade((score + curve).clamp(0, 100));

