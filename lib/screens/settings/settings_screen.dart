import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final settings = context.watch<SettingsProvider>();
    final isAr = settings.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(t.translate('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: AppTheme.primaryBlue),
                  title: Text(t.translate('language')),
                  subtitle: Text(isAr
                      ? t.translate('arabic')
                      : t.translate('english')),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _LangOption(
                          label: 'العربية',
                          selected: isAr,
                          onTap: () =>
                              settings.setLocale(const Locale('ar')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LangOption(
                          label: 'English',
                          selected: !isAr,
                          onTap: () =>
                              settings.setLocale(const Locale('en')),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined,
                      color: AppTheme.primaryBlue),
                  title: Text(t.translate('theme')),
                  subtitle: Text(_themeLabel(settings.themeMode, t)),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ThemeOption(
                          icon: Icons.light_mode,
                          label: t.translate('lightMode'),
                          selected:
                              settings.themeMode == ThemeMode.light,
                          onTap: () =>
                              settings.setThemeMode(ThemeMode.light),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ThemeOption(
                          icon: Icons.dark_mode,
                          label: t.translate('darkMode'),
                          selected:
                              settings.themeMode == ThemeMode.dark,
                          onTap: () =>
                              settings.setThemeMode(ThemeMode.dark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading:
                  const Icon(Icons.info_outline, color: AppTheme.primaryBlue),
              title: Text(t.translate('about')),
              subtitle: const Text('ECMS v1.0.0'),
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode, AppLocalizations t) {
    switch (mode) {
      case ThemeMode.light:
        return t.translate('lightMode');
      case ThemeMode.dark:
        return t.translate('darkMode');
      case ThemeMode.system:
        return t.translate('systemMode');
    }
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.primaryBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? AppTheme.primaryBlue : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.primaryBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? AppTheme.primaryBlue : Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? AppTheme.primaryBlue : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
