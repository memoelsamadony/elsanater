import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RoleBasedWidget extends StatelessWidget {
  final List<String> requiredRoles;
  final Widget child;
  final Widget? fallback;

  const RoleBasedWidget({
    super.key,
    required this.requiredRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.hasAnyRole(requiredRoles)) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}
