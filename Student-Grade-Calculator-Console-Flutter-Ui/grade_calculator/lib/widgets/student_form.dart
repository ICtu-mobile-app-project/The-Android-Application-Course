import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';

class StudentForm extends StatefulWidget {
  final Student? initialStudent;
  final void Function(Student student) onSave;

  const StudentForm({super.key, this.initialStudent, required this.onSave});

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _scoreController;
  bool _scoreUnknown = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialStudent?.name ?? '');
    _scoreController = TextEditingController(
        text: widget.initialStudent?.score?.toString() ?? '');
    _scoreUnknown = widget.initialStudent != null && widget.initialStudent!.score == null;
  }

  @override
  void didUpdateWidget(StudentForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStudent != oldWidget.initialStudent) {
      _nameController.text = widget.initialStudent?.name ?? '';
      _scoreController.text = widget.initialStudent?.score?.toString() ?? '';
      _scoreUnknown = widget.initialStudent != null && widget.initialStudent!.score == null;
    }
  }

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

    widget.onSave(Student(name: name, score: score));

    if (widget.initialStudent == null) {
      _nameController.clear();
      _scoreController.clear();
      setState(() => _scoreUnknown = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialStudent != null;

    return Card(
      elevation: isEditing ? 8 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isEditing
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Student' : 'Add a Student',
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
                  icon: Icon(isEditing ? Icons.save : Icons.add),
                  label: Text(isEditing ? 'Update Student' : 'Add Student'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEditing ? Colors.orange.shade700 : null,
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
