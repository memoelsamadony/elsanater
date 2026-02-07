import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class SettingsProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.light;

  SettingsProvider() {
    _loadSettings();
  }

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(AppConstants.localeKey) ?? 'ar';
    _locale = Locale(localeCode);

    final themeModeIndex = prefs.getInt(AppConstants.themeModeKey) ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];

    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.localeKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.themeModeKey, mode.index);
    notifyListeners();
  }
}
