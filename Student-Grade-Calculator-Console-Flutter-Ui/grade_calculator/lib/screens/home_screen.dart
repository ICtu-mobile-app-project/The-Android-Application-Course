import 'package:flutter/material.dart';
import '../models/student.dart';
import '../utils/grade_calculator.dart';
import '../utils/file_service.dart';
import '../widgets/student_form.dart';
import '../widgets/student_card.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen(
      {super.key, required this.onToggleTheme, required this.isDarkMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Student> _students = [];
  bool _importing = false;
  bool _exporting = false;

  void _addStudent(Student s) {
    setState(() => _students.add(s));
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear all students?'),
        content: const Text('This will remove all students from the list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _students.clear());
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ── Import Excel ──────────────────────────────────────────────────────────
  Future<void> _importExcel() async {
    setState(() => _importing = true);
    try {
      // Higher-order: pass getGrade as the grader lambda so grading logic is
      // injected into the file parser rather than hardcoded inside it.
      final result = await importStudentsFromExcel(grader: getGrade);

      if (result == null) return; // user cancelled the picker

      // Ask whether to append or replace
      if (!mounted) return;
      final bool replace = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Import students'),
              content: Text(result.summary),
              actions: [
                if (_students.isNotEmpty)
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Replace list',
                        style: TextStyle(color: Colors.red)),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Append to list'),
                ),
              ],
            ),
          ) ??
          false;

      setState(() {
        if (replace) _students.clear();
        _students.addAll(result.students);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${result.students.length} student(s) imported successfully.'),
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
      // Higher-order: rowBuilder lambda maps each Student to its Excel row data.
      await exportStudentsToExcel(
        students: _students,
        rowBuilder: (student) => [
          student.name,
          student.score?.toString() ?? 'N/A',
          student.grade,
        ],
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export ready — use the share sheet to save or send.'),
          backgroundColor: Color(0xFF1A73E8),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
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
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: kAppGradient,
                ),
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
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_students.length} student${_students.length == 1 ? '' : 's'} added',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                    widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: widget.onToggleTheme,
                color: Colors.white,
              ),
              if (_students.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _clearAll,
                  color: Colors.white,
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StudentForm(onAdd: _addStudent),
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
                      label: 'Import Excel',
                      loading: _importing,
                      onTap: _importing ? null : _importExcel,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.download,
                      label: 'Export Excel',
                      loading: _exporting,
                      onTap: (_students.isEmpty || _exporting)
                          ? null
                          : _exportExcel,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: StudentCard(
                      key: ValueKey('${_students[index].name}_$index'),
                      student: _students[index],
                      index: index,
                    ),
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

// ── Reusable action button ───────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              enabled ? Theme.of(context).colorScheme.primary : Colors.grey,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No students yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a student manually or import an Excel file',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
