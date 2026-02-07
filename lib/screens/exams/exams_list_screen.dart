import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../models/exam_model.dart';
import '../../models/teacher_model.dart';
import '../../providers/exam_provider.dart';
import '../../services/teacher_service.dart';
import '../../core/network/api_client.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class ExamsListScreen extends StatefulWidget {
  const ExamsListScreen({super.key});

  @override
  State<ExamsListScreen> createState() => _ExamsListScreenState();
}

class _ExamsListScreenState extends State<ExamsListScreen> {
  List<Teacher> _teachers = [];
  Teacher? _selectedTeacher;
  TeacherSubject? _selectedSubject;
  int? _selectedLevel;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final client = await ApiClient.getInstance();
    final service = TeacherService(client);
    final response = await service.getTeachers();
    if (response.success && response.data != null && mounted) {
      setState(() => _teachers = response.data!);
    }
  }

  void _fetchExams() {
    if (_selectedTeacher != null &&
        _selectedSubject != null &&
        _selectedLevel != null) {
      context.read<ExamProvider>().fetchExams(
            level: _selectedLevel!,
            teacherId: _selectedTeacher!.id,
            subjectId: _selectedSubject!.id,
          );
    }
  }

  void _showExamForm({Exam? exam}) {
    final t = context.tr;
    final titleCtrl = TextEditingController(text: exam?.title ?? '');
    final fullMarkCtrl =
        TextEditingController(text: exam?.fullMark.toString() ?? '');
    final successMarkCtrl =
        TextEditingController(text: exam?.successMark.toString() ?? '');
    final noteCtrl = TextEditingController(text: exam?.note ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            Text(exam == null ? t.translate('addExam') : t.translate('editExam')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration:
                    InputDecoration(labelText: t.translate('examTitle')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fullMarkCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: t.translate('fullMark')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: successMarkCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: t.translate('successMark')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(labelText: t.translate('note')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final newExam = Exam(
                title: titleCtrl.text.trim(),
                fullMark: double.tryParse(fullMarkCtrl.text) ?? 100,
                successMark: double.tryParse(successMarkCtrl.text) ?? 50,
                level: _selectedLevel!,
                teacherId: _selectedTeacher!.id,
                subjectId: _selectedSubject!.id,
                note: noteCtrl.text.trim(),
              );
              final provider = context.read<ExamProvider>();
              bool success;
              if (exam == null) {
                success = await provider.addExam(newExam);
              } else {
                success = await provider.editExam(exam.id!, newExam);
              }
              if (success && ctx.mounted) {
                Navigator.pop(ctx);
                _fetchExams();
              }
            },
            child: Text(t.translate('save')),
          ),
        ],
      ),
    );
  }

  void _deleteExam(Exam exam) {
    final t = context.tr;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.translate('deleteExam')),
        content: Text(t.translate('deleteExamConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.translate('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await context.read<ExamProvider>().deleteExam(exam.id!);
              if (success) _fetchExams();
            },
            child: Text(t.translate('delete'),
                style: const TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final provider = context.watch<ExamProvider>();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final levels = isAr ? AppConstants.schoolLevelsAr : AppConstants.schoolLevelsEn;

    return Scaffold(
      appBar: AppBar(title: Text(t.translate('exams'))),
      floatingActionButton: (_selectedTeacher != null &&
              _selectedSubject != null &&
              _selectedLevel != null)
          ? FloatingActionButton(
              onPressed: () => _showExamForm(),
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  DropdownButtonFormField<Teacher>(
                    decoration:
                        InputDecoration(labelText: t.translate('selectTeacher')),
                    items: _teachers
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t.name)))
                        .toList(),
                    onChanged: (t) {
                      setState(() {
                        _selectedTeacher = t;
                        _selectedSubject = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TeacherSubject>(
                    decoration:
                        InputDecoration(labelText: t.translate('selectSubject')),
                    items: _selectedTeacher?.subjects
                            ?.map((s) =>
                                DropdownMenuItem(value: s, child: Text(s.name)))
                            .toList() ??
                        [],
                    onChanged: (s) {
                      setState(() => _selectedSubject = s);
                      _fetchExams();
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    decoration:
                        InputDecoration(labelText: t.translate('selectLevel')),
                    items: levels.entries
                        .map((e) => DropdownMenuItem(
                            value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedLevel = v);
                      _fetchExams();
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const LoadingWidget()
                : provider.exams.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.quiz_outlined,
                        message: t.translate('noExams'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: provider.exams.length,
                        itemBuilder: (context, index) {
                          final exam = provider.exams[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(exam.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                '${t.translate('fullMark')}: ${exam.fullMark.toInt()} | ${t.translate('successMark')}: ${exam.successMark.toInt()}',
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text(t.translate('edit')),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(t.translate('delete'),
                                        style: const TextStyle(
                                            color: AppTheme.error)),
                                  ),
                                ],
                                onSelected: (v) {
                                  if (v == 'edit') _showExamForm(exam: exam);
                                  if (v == 'delete') _deleteExam(exam);
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
