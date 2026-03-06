import 'package:flutter/material.dart';
import '../models/student.dart';
import '../utils/grade_calculator.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final int index;

  const StudentCard({super.key, required this.student, required this.index});

  @override
  Widget build(BuildContext context) {
    final bool hasScore = student.score != null;
    // extensions defined in grade_calculator.dart
    final String grade = student.grade;
    final Color accentColor = student.accent;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: accentColor.withValues(alpha: 0.2),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  if (hasScore)
                    Text(
                      'Score: ${student.score} • Grade: $grade',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    Text(
                      'No score available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                grade,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
