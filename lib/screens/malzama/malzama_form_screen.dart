import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/network/api_client.dart';
import '../../models/malzama_model.dart';
import '../../models/teacher_model.dart';
import '../../providers/malzama_provider.dart';
import '../../services/teacher_service.dart';
import '../../widgets/loading_widget.dart';

class MalzamaFormScreen extends StatefulWidget {
  const MalzamaFormScreen({super.key});

  @override
  State<MalzamaFormScreen> createState() => _MalzamaFormScreenState();
}

class _MalzamaFormScreenState extends State<MalzamaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  List<Teacher> _teachers = [];
  Teacher? _selectedTeacher;
  TeacherSubject? _selectedSubject;
  int? _selectedLevel;
  List<Group> _availableGroups = [];
  final Set<int> _selectedGroupIds = {};
  bool _loading = true;
  int? _editingId;

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
      setState(() {
        _teachers = response.data!;
        _loading = false;
      });
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final malzamaId = ModalRoute.of(context)?.settings.arguments as int?;
    if (malzamaId != null && _editingId == null) {
      _editingId = malzamaId;
      _loadExisting(malzamaId);
    }
  }

  Future<void> _loadExisting(int id) async {
    final provider = context.read<MalzamaProvider>();
    final m = await provider.getMalzamaById(id);
    if (m != null && mounted) {
      setState(() {
        _titleCtrl.text = m.title;
        _priceCtrl.text = m.price.toString();
        _selectedLevel = m.level;
        if (m.groupIds != null) {
          _selectedGroupIds.addAll(m.groupIds!);
        }
      });
    }
  }

  Future<void> _fetchGroups() async {
    if (_selectedTeacher == null ||
        _selectedSubject == null ||
        _selectedLevel == null) {
      return;
    }

    final provider = context.read<MalzamaProvider>();
    final groups = await provider.getMatchingGroups(
      teacherId: _selectedTeacher!.id,
      subjectId: _selectedSubject!.id,
      level: _selectedLevel!,
    );
    if (mounted) setState(() => _availableGroups = groups);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTeacher == null ||
        _selectedSubject == null ||
        _selectedLevel == null) {
      return;
    }

    final provider = context.read<MalzamaProvider>();
    final malzama = Malzama(
      id: _editingId,
      title: _titleCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0,
      teacherId: _selectedTeacher!.id,
      subjectId: _selectedSubject!.id,
      level: _selectedLevel!,
      groupIds: _selectedGroupIds.toList(),
    );

    bool success;
    if (_editingId != null) {
      success = await provider.updateMalzama(_editingId!, malzama);
    } else {
      success = await provider.createMalzama(malzama);
    }

    if (success && mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final provider = context.watch<MalzamaProvider>();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final levels =
        isAr ? AppConstants.schoolLevelsAr : AppConstants.schoolLevelsEn;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_editingId != null
              ? t.translate('editMalzama')
              : t.translate('addMalzama')),
        ),
        body: const LoadingWidget(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingId != null
            ? t.translate('editMalzama')
            : t.translate('addMalzama')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: InputDecoration(
                            labelText: t.translate('malzamaTitle')),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? t.translate('fieldRequired')
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            InputDecoration(labelText: t.translate('price')),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? t.translate('fieldRequired')
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Teacher>(
                        decoration: InputDecoration(
                            labelText: t.translate('selectTeacher')),
                        items: _teachers
                            .map((teacher) => DropdownMenuItem(
                                value: teacher, child: Text(teacher.name)))
                            .toList(),
                        onChanged: (teacher) {
                          setState(() {
                            _selectedTeacher = teacher;
                            _selectedSubject = null;
                            _availableGroups = [];
                            _selectedGroupIds.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<TeacherSubject>(
                        decoration: InputDecoration(
                            labelText: t.translate('selectSubject')),
                        items: _selectedTeacher?.subjects
                                ?.map((s) => DropdownMenuItem(
                                    value: s, child: Text(s.name)))
                                .toList() ??
                            [],
                        onChanged: (s) {
                          setState(() => _selectedSubject = s);
                          _fetchGroups();
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                            labelText: t.translate('selectLevel')),
                        items: levels.entries
                            .map((e) => DropdownMenuItem(
                                value: e.key, child: Text(e.value)))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _selectedLevel = v);
                          _fetchGroups();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (_availableGroups.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.translate('selectGroups'),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...List.generate(_availableGroups.length, (i) {
                          final g = _availableGroups[i];
                          return CheckboxListTile(
                            title: Text(g.title),
                            subtitle: g.studentCount != null
                                ? Text(
                                    '${g.studentCount} ${t.translate('students')}')
                                : null,
                            value: _selectedGroupIds.contains(g.id),
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _selectedGroupIds.add(g.id);
                                } else {
                                  _selectedGroupIds.remove(g.id);
                                }
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _save,
                  child: Text(provider.isLoading
                      ? t.translate('loading')
                      : t.translate('save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
