import 'package:flutter/material.dart';
import '../models/student.dart';
import '../utils/grade_calculator.dart';
import '../utils/file_service.dart';
import '../widgets/gradient_header.dart';
import '../widgets/student_form.dart';
import '../widgets/student_card.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
      backgroundColor: kScaffoldBg,
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: GradientHeader(
              studentCount: _students.length,
              onClearAll: _clearAll,
            ),
          ),

          // ── Add-student form (no longer overlapping the header) ────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: StudentForm(onAdd: _addStudent),
            ),
          ),

          // ── Import / Export action row ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  // Import button — always available
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.upload_file_rounded,
                      label: 'Import Excel',
                      loading: _importing,
                      onTap: _importing ? null : _importExcel,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00796B), Color(0xFF1A73E8)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Export button — disabled when no students
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.download_rounded,
                      label: 'Export Excel',
                      loading: _exporting,
                      onTap: (_students.isEmpty || _exporting)
                          ? null
                          : _exportExcel,
                      gradient: _students.isEmpty
                          ? LinearGradient(
                              colors: [
                                Colors.grey.shade400,
                                Colors.grey.shade400
                              ],
                            )
                          : kButtonGradient,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Results list (or empty state) ──────────────────────────────────
          _students.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: StudentCard(
                        key: ValueKey('${_students[index].name}_$index'),
                        student: _students[index],
                        index: index,
                      ),
                    ),
                    childCount: _students.length,
                  ),
                ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── Reusable gradient action button ───────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool loading;
  final VoidCallback? onTap;
  final LinearGradient gradient;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.loading,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null && !loading;
    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty state illustration ───────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Icon(Icons.school_outlined, size: 72, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(
          'No students yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add a student manually or import an Excel file',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        ),
      ],
    );
  }
}


