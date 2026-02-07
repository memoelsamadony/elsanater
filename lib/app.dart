import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/change_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/students/students_list_screen.dart';
import 'screens/students/student_detail_screen.dart';
import 'screens/attendance/attendance_filter_screen.dart';
import 'screens/attendance/attendance_history_screen.dart';
import 'screens/attendance/attendance_day_screen.dart';
import 'screens/attendance/student_history_screen.dart';
import 'screens/exams/exams_list_screen.dart';
import 'screens/exams/exam_marks_screen.dart';
import 'screens/malzama/malzama_list_screen.dart';
import 'screens/malzama/malzama_form_screen.dart';
import 'screens/malzama/malzama_students_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';

class ECMSApp extends StatelessWidget {
  const ECMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ECMS',

      // ── Theme ──
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,

      // ── Localization ──
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Routes ──
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/students': (context) => const StudentsListScreen(),
        '/student-detail': (context) => const StudentDetailScreen(),
        '/attendance': (context) => const AttendanceFilterScreen(),
        '/attendance-history': (context) => const AttendanceHistoryScreen(),
        '/attendance-day': (context) => const AttendanceDayScreen(),
        '/student-attendance-history': (context) =>
            const StudentHistoryScreen(),
        '/exams': (context) => const ExamsListScreen(),
        '/exam-marks': (context) => const ExamMarksScreen(),
        '/malzamas': (context) => const MalzamaListScreen(),
        '/malzama-form': (context) => const MalzamaFormScreen(),
        '/malzama-students': (context) => const MalzamaStudentsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
