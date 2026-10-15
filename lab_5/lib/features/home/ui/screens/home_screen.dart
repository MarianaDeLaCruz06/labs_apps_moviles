import 'package:flutter/material.dart';

import 'package:moviles_auth/components/error_message.dart';
import 'package:moviles_auth/components/primary_button.dart';
import 'package:moviles_auth/components/profile_field.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:moviles_auth/theme/app_theme.dart';

/// Shows the profile of the signed in user and lets them sign out.
class HomeScreen extends StatefulWidget {
  final String username;
  final String fullName;
  final String email;
  final SignOutUseCase signOutUseCase;

  const HomeScreen({
    super.key,
    required this.username,
    required this.fullName,
    required this.email,
    required this.signOutUseCase,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSigningOut = false;
  String? _errorMessage;

  Future<void> _signOut() async {
    if (_isSigningOut) return;

    setState(() {
      _isSigningOut = true;
      _errorMessage = null;
    });

    try {
      await widget.signOutUseCase();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSigningOut = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  widget.fullName.isEmpty
                      ? '?'
                      : widget.fullName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surface,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '@${widget.username}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              ProfileField(
                icon: Icons.alternate_email,
                label: 'Nombre de usuario',
                value: widget.username,
              ),
              const SizedBox(height: 12),
              ProfileField(
                icon: Icons.person_outline,
                label: 'Nombre completo',
                value: widget.fullName,
              ),
              const SizedBox(height: 12),
              ProfileField(
                icon: Icons.mail_outline,
                label: 'Correo',
                value: widget.email,
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null) ...[
                ErrorMessage(message: _errorMessage!),
                const SizedBox(height: 16),
              ],
              PrimaryButton(
                label: 'Cerrar sesión',
                isLoading: _isSigningOut,
                onPressed: _signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
