import 'package:flutter/material.dart';
import '../models/student.dart';
import '../utils/grade_calculator.dart';
import '../utils/file_service.dart';
import '../widgets/gradient_header.dart';
import '../widgets/student_form.dart';
import '../widgets/student_card.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({super.key, required this.onToggleTheme, required this.isDarkMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Student> _students = [];
  int? _selectedStudentIndex;
  bool _importing = false;
  bool _exporting = false;

  void _handleSaveStudent(Student s) {
    setState(() {
      if (_selectedStudentIndex != null) {
        _students[_selectedStudentIndex!] = s;
        _selectedStudentIndex = null;
      } else {
        _students.add(s);
      }
    });
  }

  void _deleteSelectedStudent() {
    if (_selectedStudentIndex != null && _selectedStudentIndex! < _students.length) {
      final name = _students[_selectedStudentIndex!].name;
      setState(() {
        _students.removeAt(_selectedStudentIndex!);
        _selectedStudentIndex = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed $name from list'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear all students?'),
        content: const Text('This will remove everyone from the list. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _students.clear();
                _selectedStudentIndex = null;
              });
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ── Import Excel ──────────────────────────────────────────────────────────
  Future<void> _importExcel() async {
    setState(() => _importing = true);
    try {
      final result = await importStudentsFromExcel(grader: getGrade);
      if (result == null) return;

      if (!mounted) return;
      final bool replace = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Import students'),
              content: Text(result.summary),
              actions: [
                if (_students.isNotEmpty)
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Replace list', style: TextStyle(color: Colors.red)),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Append to list'),
                ),
              ],
            ),
          ) ?? false;

      setState(() {
        if (replace) {
          _students.clear();
          _selectedStudentIndex = null;
        }
        _students.addAll(result.students);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.students.length} student(s) imported.'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  // ── Export Excel ──────────────────────────────────────────────────────────
  Future<void> _exportExcel() async {
    setState(() => _exporting = true);
    try {
      await exportStudentsToExcel(
        students: _students,
        rowBuilder: (student) => [
          student.name,
          student.score?.toString() ?? 'N/A',
          student.grade,
        ],
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false, // Prevents default leading widgets
            leading: _selectedStudentIndex != null
                ? IconButton(
                    tooltip: 'Delete selected student',
                    icon: const Icon(Icons.delete, color: Colors.white, size: 28),
                    onPressed: _deleteSelectedStudent,
                  )
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: kAppGradient),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Grade Calculator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_students.length} student${_students.length == 1 ? '' : 's'} added',
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: widget.onToggleTheme,
                color: Colors.white,
              ),
              if (_students.isNotEmpty)
                IconButton(
                  tooltip: 'Clear all students',
                  icon: const Icon(Icons.delete_forever_outlined),
                  onPressed: _clearAll,
                  color: Colors.white,
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StudentForm(
                key: ValueKey('form_${_selectedStudentIndex ?? -1}'),
                initialStudent: _selectedStudentIndex != null ? _students[_selectedStudentIndex!] : null,
                onSave: _handleSaveStudent,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.upload_file,
                      label: 'Import',
                      loading: _importing,
                      onTap: _importing ? null : _importExcel,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.download,
                      label: 'Export',
                      loading: _exporting,
                      onTap: (_students.isEmpty || _exporting) ? null : _exportExcel,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_students.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: StudentCard(
                    key: ValueKey('${_students[index].name}_$index'),
                    student: _students[index],
                    index: index,
                    isSelected: _selectedStudentIndex == index,
                    onTap: () {
                      setState(() {
                        _selectedStudentIndex = (_selectedStudentIndex == index) ? null : index;
                      });
                    },
                  ),
                ),
                childCount: _students.length,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: loading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? Theme.of(context).colorScheme.primary : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No students yet', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
