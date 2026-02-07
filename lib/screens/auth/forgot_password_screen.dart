import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 0; // 0: email, 1: OTP, 2: new password
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _resetToken;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_emailController.text.trim().isEmpty) return;
    final auth = context.read<AuthProvider>();
    final success =
        await auth.sendOtpResetPassword(_emailController.text.trim());
    if (success && mounted) {
      setState(() => _step = 1);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) return;
    final auth = context.read<AuthProvider>();
    final token = await auth.confirmResetPasswordOtp(
      email: _emailController.text.trim(),
      otp: _otpController.text.trim(),
    );
    if (token != null && mounted) {
      _resetToken = token;
      setState(() => _step = 2);
    }
  }

  Future<void> _resetPassword() async {
    final t = context.tr;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('passwordsDoNotMatch'))),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.resetPassword(
      email: _emailController.text.trim(),
      token: _resetToken ?? '',
      newPassword: _passwordController.text,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('resetSuccess'))),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t.translate('resetPassword'))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_step == 0) ...[
                    const Icon(Icons.email_outlined,
                        size: 48, color: AppTheme.primaryBlue),
                    const SizedBox(height: 16),
                    Text(t.translate('enterEmail'),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: t.translate('email'),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildErrorAndButton(
                      auth,
                      label: t.translate('sendCode'),
                      loadingLabel: t.translate('sendingCode'),
                      onPressed: _sendOtp,
                    ),
                  ],
                  if (_step == 1) ...[
                    const Icon(Icons.sms_outlined,
                        size: 48, color: AppTheme.primaryBlue),
                    const SizedBox(height: 16),
                    Text(t.translate('enterOtp'), textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24, letterSpacing: 8),
                      decoration: InputDecoration(
                        labelText: t.translate('otpCode'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildErrorAndButton(
                      auth,
                      label: t.translate('verifyCode'),
                      loadingLabel: t.translate('verifying'),
                      onPressed: _verifyOtp,
                    ),
                  ],
                  if (_step == 2) ...[
                    const Icon(Icons.lock_reset,
                        size: 48, color: AppTheme.primaryBlue),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: t.translate('newPassword'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: t.translate('confirmPassword'),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildErrorAndButton(
                      auth,
                      label: t.translate('resetPassword'),
                      loadingLabel: t.translate('resetting'),
                      onPressed: _resetPassword,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorAndButton(
    AuthProvider auth, {
    required String label,
    required String loadingLabel,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (auth.error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              context.tr.translate(auth.error!),
              style: const TextStyle(color: AppTheme.error),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: auth.isLoading ? null : onPressed,
            child: Text(auth.isLoading ? loadingLabel : label),
          ),
        ),
      ],
    );
  }
}
