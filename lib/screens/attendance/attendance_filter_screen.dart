import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/loading_widget.dart';

class AttendanceFilterScreen extends StatefulWidget {
  const AttendanceFilterScreen({super.key});

  @override
  State<AttendanceFilterScreen> createState() => _AttendanceFilterScreenState();
}

class _AttendanceFilterScreenState extends State<AttendanceFilterScreen> {
  AttendanceTeacher? _selectedTeacher;
  AttendanceSubject? _selectedSubject;
  int? _selectedLevel;
  AttendanceGroup? _selectedGroup;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchFilterOptions();
    });
  }

  void _onTeacherChanged(AttendanceTeacher? teacher) {
    setState(() {
      _selectedTeacher = teacher;
      _selectedSubject = null;
      _selectedGroup = null;
    });
    if (teacher != null) {
      context.read<AttendanceProvider>().fetchSubjectsByTeacher(teacher.id);
    }
  }

  void _onSubjectChanged(AttendanceSubject? subject) {
    setState(() {
      _selectedSubject = subject;
      _selectedGroup = null;
    });
    _fetchGroups();
  }

  void _onLevelChanged(int? level) {
    setState(() {
      _selectedLevel = level;
      _selectedGroup = null;
    });
    _fetchGroups();
  }

  void _fetchGroups() {
    if (_selectedTeacher != null &&
        _selectedSubject != null &&
        _selectedLevel != null) {
      context.read<AttendanceProvider>().fetchGroups(
            teacherId: _selectedTeacher!.id,
            level: _selectedLevel!,
            subjectId: _selectedSubject!.id,
          );
    }
  }

  void _openGroup() {
    if (_selectedGroup != null) {
      Navigator.pushNamed(
        context,
        '/attendance-history',
        arguments: {
          'groupId': _selectedGroup!.id,
          'groupTitle': _selectedGroup!.title,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final provider = context.watch<AttendanceProvider>();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final levels = isAr ? AppConstants.schoolLevelsAr : AppConstants.schoolLevelsEn;

    return Scaffold(
      appBar: AppBar(title: Text(t.translate('attendance'))),
      body: provider.isLoading && provider.filterOptions == null
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<AttendanceTeacher>(
                            decoration: InputDecoration(
                                labelText: t.translate('selectTeacher')),
                            items: provider.filterOptions?.teachers
                                    .map((t) => DropdownMenuItem(
                                        value: t, child: Text(t.name)))
                                    .toList() ??
                                [],
                            onChanged: _onTeacherChanged,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<AttendanceSubject>(
                            decoration: InputDecoration(
                                labelText: t.translate('selectSubject')),
                            items: provider.subjects
                                .map((s) => DropdownMenuItem(
                                    value: s, child: Text(s.name)))
                                .toList(),
                            onChanged: _onSubjectChanged,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                                labelText: t.translate('selectLevel')),
                            items: levels.entries
                                .map((e) => DropdownMenuItem(
                                    value: e.key, child: Text(e.value)))
                                .toList(),
                            onChanged: _onLevelChanged,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<AttendanceGroup>(
                            decoration: InputDecoration(
                                labelText: t.translate('selectGroup')),
                            items: provider.groups
                                .map((g) => DropdownMenuItem(
                                    value: g, child: Text(g.title)))
                                .toList(),
                            onChanged: (g) =>
                                setState(() => _selectedGroup = g),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _selectedGroup != null ? _openGroup : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(t.translate('attendanceHistory')),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
