import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final t = context.tr;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryBlue),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 35, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    auth.user?.name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    auth.user?.email ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          _DrawerItem(
            icon: Icons.home_outlined,
            label: t.translate('home'),
            onTap: () => _navigateTo(context, '/home'),
          ),
          if (auth.hasAnyRole([
            AppConstants.roleAdmin,
            AppConstants.roleCenterOwner,
            AppConstants.roleViewStudents,
          ]))
            _DrawerItem(
              icon: Icons.people_outline,
              label: t.translate('students'),
              onTap: () => _navigateTo(context, '/students'),
            ),
          if (auth.hasAnyRole([
            AppConstants.roleAdmin,
            AppConstants.roleCenterOwner,
            AppConstants.roleViewStudentAttendanceHistory,
          ]))
            _DrawerItem(
              icon: Icons.fact_check_outlined,
              label: t.translate('attendance'),
              onTap: () => _navigateTo(context, '/attendance'),
            ),
          _DrawerItem(
            icon: Icons.quiz_outlined,
            label: t.translate('exams'),
            onTap: () => _navigateTo(context, '/exams'),
          ),
          if (auth.hasAnyRole([
            AppConstants.roleAdmin,
            AppConstants.roleCenterOwner,
            AppConstants.roleViewMalzamas,
          ]))
            _DrawerItem(
              icon: Icons.menu_book_outlined,
              label: t.translate('malzamas'),
              onTap: () => _navigateTo(context, '/malzamas'),
            ),
          const Divider(),
          _DrawerItem(
            icon: Icons.person_outline,
            label: t.translate('profile'),
            onTap: () => _navigateTo(context, '/profile'),
          ),
          _DrawerItem(
            icon: Icons.settings_outlined,
            label: t.translate('settings'),
            onTap: () => _navigateTo(context, '/settings'),
          ),
          const Spacer(),
          _DrawerItem(
            icon: Icons.logout,
            label: t.translate('logout'),
            onTap: () => _confirmLogout(context, auth, t),
            color: AppTheme.error,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  void _confirmLogout(
    BuildContext context,
    AuthProvider auth,
    AppLocalizations t,
  ) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.translate('logout')),
        content: Text(t.translate('logoutConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.translate('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            child: Text(
              t.translate('logout'),
              style: const TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}
