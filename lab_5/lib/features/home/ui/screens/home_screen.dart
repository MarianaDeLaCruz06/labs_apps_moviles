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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.secondary, AppColors.primary],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.22),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surface.withValues(alpha: 0.72),
                              width: 3,
                            ),
                          ),
                          child: Text(
                            widget.fullName.isEmpty
                                ? '?'
                                : widget.fullName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.surface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.fullName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.surface,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '@${widget.username}',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.surface.withValues(alpha: 0.86),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Información personal',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ProfileField(
                    icon: Icons.alternate_email,
                    label: 'Nombre de usuario',
                    value: widget.username,
                  ),
                  const SizedBox(height: 8),
                  ProfileField(
                    icon: Icons.person_outline,
                    label: 'Nombre completo',
                    value: widget.fullName,
                  ),
                  const SizedBox(height: 8),
                  ProfileField(
                    icon: Icons.mail_outline,
                    label: 'Correo',
                    value: widget.email,
                  ),
                  const SizedBox(height: 18),
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
        ),
      ),
    );
  }
}
