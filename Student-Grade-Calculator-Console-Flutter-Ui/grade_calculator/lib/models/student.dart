// Student data model
// score is nullable — null means the score is missing/unknown
class Student {
  final String name;
  final int? score;

  const Student({required this.name, this.score});

  @override
  String toString() {
    if (score == null) return 'No score for $name';
    return '$name scored $score : Grade ${_grade()}';
  }

  String _grade() {
    if (score == null) return '–';
    if (score! >= 90) return 'A';
    if (score! >= 80) return 'B';
    if (score! >= 70) return 'C';
    if (score! >= 60) return 'D';
    return 'F';
  }
}
