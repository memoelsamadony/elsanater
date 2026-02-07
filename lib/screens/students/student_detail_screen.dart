import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/student_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/loading_widget.dart';

class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({super.key});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  Student? _student;
  List<StudentGroup> _groups = [];
  bool _loading = true;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _parentNameCtrl;
  late TextEditingController _parentPhoneCtrl;
  int _schoolLevel = 0;
  bool _gender = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _parentNameCtrl = TextEditingController();
    _parentPhoneCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _loadData();
  }

  Future<void> _loadData() async {
    final studentId = ModalRoute.of(context)!.settings.arguments as int;
    final provider = context.read<StudentProvider>();

    final student = await provider.getStudentById(studentId);
    final groups = await provider.getStudentGroups(studentId);

    if (mounted) {
      setState(() {
        _student = student;
        _groups = groups;
        _loading = false;
        if (student != null) {
          _nameCtrl.text = student.name;
          _phoneCtrl.text = student.phone ?? '';
          _addressCtrl.text = student.address ?? '';
          _parentNameCtrl.text = student.parentName ?? '';
          _parentPhoneCtrl.text = student.parentPhone ?? '';
          _schoolLevel = student.schoolLevel;
          _gender = student.gender;
        }
      });
    }
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<StudentProvider>();
    final success = await provider.updateStudent(
      _student!.id,
      UpdateStudentRequest(
        id: _student!.id,
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        schoolLevel: _schoolLevel,
        address: _addressCtrl.text.trim(),
        gender: _gender,
        parentName: _parentNameCtrl.text.trim(),
        parentPhone: _parentPhoneCtrl.text.trim(),
      ),
    );
    if (success && mounted) {
      setState(() => _isEditing = false);
      _loadData();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _parentNameCtrl.dispose();
    _parentPhoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final auth = context.watch<AuthProvider>();
    final canEdit = auth.hasAnyRole([
      AppConstants.roleAdmin,
      AppConstants.roleCenterOwner,
      AppConstants.roleEditStudent,
    ]);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(t.translate('studentDetails'))),
        body: const LoadingWidget(),
      );
    }

    if (_student == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.translate('studentDetails'))),
        body: Center(child: Text(t.translate('notFound'))),
      );
    }

    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final levels = isAr ? AppConstants.schoolLevelsAr : AppConstants.schoolLevelsEn;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing
            ? t.translate('editStudent')
            : t.translate('studentDetails')),
        actions: [
          if (canEdit && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _field(t.translate('studentName'), _nameCtrl,
                          required: true),
                      _field(t.translate('studentPhone'), _phoneCtrl),
                      _field(t.translate('address'), _addressCtrl),
                      const SizedBox(height: 12),
                      if (_isEditing) ...[
                        DropdownButtonFormField<int>(
                          initialValue: _schoolLevel,
                          decoration: InputDecoration(
                              labelText: t.translate('schoolLevel')),
                          items: levels.entries
                              .map((e) => DropdownMenuItem(
                                  value: e.key, child: Text(e.value)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _schoolLevel = v ?? 0),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(t.translate('gender')),
                            const SizedBox(width: 16),
                            ChoiceChip(
                              label: Text(t.translate('male')),
                              selected: _gender,
                              onSelected: (_) =>
                                  setState(() => _gender = true),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text(t.translate('female')),
                              selected: !_gender,
                              onSelected: (_) =>
                                  setState(() => _gender = false),
                            ),
                          ],
                        ),
                      ] else ...[
                        _infoRow(t.translate('schoolLevel'),
                            _student!.schoolLevelName ?? ''),
                        _infoRow(t.translate('gender'),
                            _student!.gender ? t.translate('male') : t.translate('female')),
                        _infoRow(t.translate('studentCode'),
                            _student!.codeId ?? '-'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.translate('parentName'),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _field(t.translate('parentName'), _parentNameCtrl),
                      _field(t.translate('parentPhone'), _parentPhoneCtrl),
                    ],
                  ),
                ),
              ),
              if (!_isEditing && _groups.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.translate('groups'),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...List.generate(_groups.length, (i) {
                          final g = _groups[i];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.group_outlined),
                            title: Text(g.title),
                            subtitle: Text(
                                '${g.teacherName ?? ''} - ${g.subjectName ?? ''}'),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
              if (_isEditing) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _isEditing = false),
                        child: Text(t.translate('cancel')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveStudent,
                        child: Text(t.translate('save')),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {bool required = false}) {
    if (!_isEditing) {
      if (ctrl.text.isEmpty) return const SizedBox.shrink();
      return _infoRow(label, ctrl.text);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (v) => v == null || v.trim().isEmpty
                ? context.tr.translate('fieldRequired')
                : null
            : null,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
