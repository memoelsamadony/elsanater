import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/exam_model.dart';
import '../../providers/attendance_provider.dart';

class ExamMarksScreen extends StatefulWidget {
  const ExamMarksScreen({super.key});

  @override
  State<ExamMarksScreen> createState() => _ExamMarksScreenState();
}

class _ExamMarksScreenState extends State<ExamMarksScreen> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveMarks() async {
    final t = context.tr;
    final provider = context.read<AttendanceProvider>();
    final day = provider.dayDetails!;

    final marks = <ExamMark>[];
    for (final student in day.students) {
      final ctrl = _controllers[student.groupStudentId];
      if (ctrl != null && ctrl.text.isNotEmpty) {
        marks.add(ExamMark(
          groupStudentId: student.groupStudentId,
          examMark: double.tryParse(ctrl.text),
        ));
      }
    }

    final success = await provider.saveExamMarks(
      attendanceDayId: day.id,
      marks: marks,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? t.translate('marksUpdated')
            : t.translate('unknownError')),
      ),
    );
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final provider = context.watch<AttendanceProvider>();
    final day = provider.dayDetails;

    if (day == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.translate('examMarks'))),
        body: Center(child: Text(t.translate('noData'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('examMarks')),
        actions: [
          TextButton.icon(
            onPressed: provider.isLoading ? null : _saveMarks,
            icon: const Icon(Icons.save, color: Colors.white),
            label: Text(t.translate('save'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: day.students.length,
        itemBuilder: (context, index) {
          final student = day.students[index];
          _controllers.putIfAbsent(
            student.groupStudentId,
            () => TextEditingController(
              text: student.examMark?.toString() ?? '',
            ),
          );

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(student.studentName),
              trailing: SizedBox(
                width: 80,
                child: TextField(
                  controller: _controllers[student.groupStudentId],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    isDense: true,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
