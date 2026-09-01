import 'package:flutter/material.dart';

import '../components/labeled_text_field.dart';
import '../components/primary_button.dart';
import '../theme/app_theme.dart';

/// Entry screen. Sends the email to the onboarding.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = '';
  String _password = '';

  void _signIn() {
    if (_email.isEmpty || _password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe tu correo y tu contraseña')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/onboarding',
      arguments: _email,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.black,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Icesi Beats',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tu música, a tu manera',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 48),
              LabeledTextField(
                label: 'Correo',
                hint: 'tunombre@icesi.edu.co',
                onChanged: (value) => _email = value,
              ),
              LabeledTextField(
                label: 'Contraseña',
                hint: '••••••••',
                isPassword: true,
                onChanged: (value) => _password = value,
              ),
              const SizedBox(height: 12),
              PrimaryButton(text: 'Entrar', onPressed: _signIn),
              const SizedBox(height: 16),
              const Text(
                '¿Olvidaste tu contraseña?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
