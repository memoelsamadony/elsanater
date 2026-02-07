import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../models/governorate_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/general_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  List<Governorate> _governorates = [];
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  int? _governorateId;
  bool? _gender;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    await auth.fetchCurrentUser();

    final client = await ApiClient.getInstance();
    final service = GeneralService(client);
    final response = await service.getGovernorates();
    if (response.success && response.data != null && mounted) {
      setState(() => _governorates = response.data!);
    }

    if (mounted && auth.user != null) {
      _populateFields(auth.user!);
    }
  }

  void _populateFields(User user) {
    _nameCtrl.text = user.name ?? '';
    _phoneCtrl.text = user.phone ?? '';
    _addressCtrl.text = user.address ?? '';
    _governorateId = user.governorateId;
    _gender = user.gender;
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(UpdateProfileRequest(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      governorateId: _governorateId,
      gender: _gender,
    ));

    if (!mounted) return;
    final t = context.tr;
    if (success) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('profileUpdated'))),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('profile')),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
              child: const Icon(Icons.person, size: 40, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 8),
            Text(user?.name ?? '',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(user?.email ?? '',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _field(t.translate('name'), _nameCtrl),
                    _field(t.translate('phone'), _phoneCtrl),
                    _field(t.translate('address'), _addressCtrl),
                    if (_editing) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                            labelText: t.translate('governorate')),
                        items: _governorates
                            .map((g) => DropdownMenuItem(
                                value: g.id, child: Text(g.name)))
                            .toList(),
                        onChanged: (v) => _governorateId = v,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(t.translate('gender')),
                          const SizedBox(width: 16),
                          ChoiceChip(
                            label: Text(t.translate('male')),
                            selected: _gender == true,
                            onSelected: (_) =>
                                setState(() => _gender = true),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text(t.translate('female')),
                            selected: _gender == false,
                            onSelected: (_) =>
                                setState(() => _gender = false),
                          ),
                        ],
                      ),
                    ] else ...[
                      _infoRow(t.translate('governorate'),
                          user?.governorateName ?? '-'),
                      _infoRow(
                          t.translate('gender'),
                          user?.gender == true
                              ? t.translate('male')
                              : user?.gender == false
                                  ? t.translate('female')
                                  : '-'),
                    ],
                  ],
                ),
              ),
            ),
            if (_editing) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (user != null) _populateFields(user);
                        setState(() => _editing = false);
                      },
                      child: Text(t.translate('cancel')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _save,
                      child: Text(auth.isLoading
                          ? t.translate('savingProfile')
                          : t.translate('save')),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/change-password'),
                icon: const Icon(Icons.lock_outline),
                label: Text(t.translate('changePassword')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    if (!_editing) return _infoRow(label, ctrl.text.isEmpty ? '-' : ctrl.text);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
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
