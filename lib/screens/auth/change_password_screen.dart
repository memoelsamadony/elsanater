import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    final t = context.tr;

    if (_newController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('passwordsDoNotMatch'))),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.changePassword(
      current: _currentController.text,
      newPassword: _newController.text,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('passwordChanged'))),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t.translate('changePassword'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _currentController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: t.translate('currentPassword'),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? t.translate('fieldRequired')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: t.translate('newPassword'),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? t.translate('fieldRequired')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: t.translate('confirmPassword'),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? t.translate('fieldRequired')
                        : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _changePassword,
                      child: Text(auth.isLoading
                          ? t.translate('changingPassword')
                          : t.translate('changePassword')),
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
