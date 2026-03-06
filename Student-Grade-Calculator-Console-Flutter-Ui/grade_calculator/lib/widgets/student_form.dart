import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';

class StudentForm extends StatefulWidget {
  final void Function(Student student) onAdd;

  const StudentForm({super.key, required this.onAdd});

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scoreController = TextEditingController();
  bool _scoreUnknown = false;

  @override
  void dispose() {
    _nameController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final int? score =
        _scoreUnknown ? null : int.tryParse(_scoreController.text.trim());

    widget.onAdd(Student(name: name, score: score));

    _nameController.clear();
    _scoreController.clear();
    setState(() => _scoreUnknown = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section label
              const Text(
                'Add a Student',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 16),

              // Name field
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter the student\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Score field
              TextFormField(
                controller: _scoreController,
                enabled: !_scoreUnknown,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Score (0 – 100)',
                  prefixIcon: const Icon(Icons.score_rounded),
                  fillColor: _scoreUnknown
                      ? Colors.grey.shade100
                      : Colors.grey.shade50,
                ),
                validator: (v) {
                  if (_scoreUnknown) return null;
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter a score or check "Score unknown"';
                  }
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 0 || n > 100) {
                    return 'Score must be between 0 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Score unknown checkbox
              GestureDetector(
                onTap: () => setState(() {
                  _scoreUnknown = !_scoreUnknown;
                  if (_scoreUnknown) _scoreController.clear();
                }),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _scoreUnknown,
                        activeColor: kBlueEnd,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) => setState(() {
                          _scoreUnknown = val ?? false;
                          if (_scoreUnknown) _scoreController.clear();
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Score unknown',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Gradient submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: kButtonGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: kOrangeStart.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text(
                      'Add Student',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
