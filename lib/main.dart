import 'package:elsanater/screens/login_screen.dart';
import 'package:elsanater/screens/signup_screen.dart';
import 'package:elsanater/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Example',
      theme: ThemeData(
        primaryColor: const Color(0xFF584BFF),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}
