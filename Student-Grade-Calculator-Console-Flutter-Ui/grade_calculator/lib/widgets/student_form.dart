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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add a Student',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter the student\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _scoreController,
                enabled: !_scoreUnknown,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Score (0 – 100)',
                  prefixIcon: const Icon(Icons.score),
                  hintText: _scoreUnknown ? 'Score unknown' : null,
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
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Score unknown'),
                value: _scoreUnknown,
                onChanged: (val) => setState(() {
                  _scoreUnknown = val ?? false;
                  if (_scoreUnknown) _scoreController.clear();
                }),
                controlAffinity: ListTileControlAffinity.leading,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Student'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
