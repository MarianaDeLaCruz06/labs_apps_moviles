import 'dart:convert';

import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'theme/app_theme.dart';

import 'package:http/http.dart' as http;

void main() {
  runApp(const IcesiBeatsApp());
}

class IcesiBeatsApp extends StatelessWidget {
  const IcesiBeatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Icesi Beats',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),

      initialRoute: '/',

      routes: {
        '/': (context) => const LoginScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/main': (context) => const MainScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
      },
    );
  }
}