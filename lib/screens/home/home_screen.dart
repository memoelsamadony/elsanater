import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppTheme.primaryBlue,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white24,
                      child:
                          Icon(Icons.person, size: 28, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${t.translate('welcome')},',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            auth.user?.name ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                if (auth.hasAnyRole([
                  AppConstants.roleAdmin,
                  AppConstants.roleCenterOwner,
                  AppConstants.roleViewStudents,
                ]))
                  _DashboardCard(
                    icon: Icons.people_outline,
                    label: t.translate('students'),
                    color: const Color(0xFF4CAF50),
                    onTap: () => Navigator.pushNamed(context, '/students'),
                  ),
                if (auth.hasAnyRole([
                  AppConstants.roleAdmin,
                  AppConstants.roleCenterOwner,
                  AppConstants.roleViewStudentAttendanceHistory,
                ]))
                  _DashboardCard(
                    icon: Icons.fact_check_outlined,
                    label: t.translate('attendance'),
                    color: const Color(0xFF2196F3),
                    onTap: () => Navigator.pushNamed(context, '/attendance'),
                  ),
                _DashboardCard(
                  icon: Icons.quiz_outlined,
                  label: t.translate('exams'),
                  color: const Color(0xFFFF9800),
                  onTap: () => Navigator.pushNamed(context, '/exams'),
                ),
                if (auth.hasAnyRole([
                  AppConstants.roleAdmin,
                  AppConstants.roleCenterOwner,
                  AppConstants.roleViewMalzamas,
                ]))
                  _DashboardCard(
                    icon: Icons.menu_book_outlined,
                    label: t.translate('malzamas'),
                    color: const Color(0xFF9C27B0),
                    onTap: () => Navigator.pushNamed(context, '/malzamas'),
                  ),
                _DashboardCard(
                  icon: Icons.person_outline,
                  label: t.translate('profile'),
                  color: const Color(0xFF607D8B),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                _DashboardCard(
                  icon: Icons.settings_outlined,
                  label: t.translate('settings'),
                  color: const Color(0xFF795548),
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
