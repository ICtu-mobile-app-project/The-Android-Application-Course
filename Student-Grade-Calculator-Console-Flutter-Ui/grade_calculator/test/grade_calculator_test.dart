import 'package:flutter_test/flutter_test.dart';
import 'package:grade_calculator/models/student.dart';
import 'package:grade_calculator/utils/grade_calculator.dart';

void main() {
  group('getGrade()', () {
    test('returns A for 90–100', () {
      expect(getGrade(100), 'A');
      expect(getGrade(90), 'A');
      expect(getGrade(95), 'A');
    });

    test('returns B for 80–89', () {
      expect(getGrade(80), 'B');
      expect(getGrade(89), 'B');
      expect(getGrade(82), 'B');
    });

    test('returns C for 70–79', () {
      expect(getGrade(70), 'C');
      expect(getGrade(79), 'C');
    });

    test('returns D for 60–69', () {
      expect(getGrade(60), 'D');
      expect(getGrade(69), 'D');
    });

    test('returns F for below 60', () {
      expect(getGrade(59), 'F');
      expect(getGrade(0), 'F');
      expect(getGrade(47), 'F');
    });
  });

  group('Student.toString()', () {
    test('prints grade message when score is present', () {
      const s = Student(name: 'Alice', score: 95);
      expect(s.toString(), 'Alice scored 95 : Grade A');
    });

    test('prints no-score message when score is null', () {
      const s = Student(name: 'Charlie', score: null);
      expect(s.toString(), 'No score for Charlie');
    });
  });
}
