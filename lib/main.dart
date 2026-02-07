import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/exam_provider.dart';
import 'providers/malzama_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiClient = await ApiClient.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => StudentProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => AttendanceProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => ExamProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => MalzamaProvider(apiClient)),
      ],
      child: const ECMSApp(),
    ),
  );
}
