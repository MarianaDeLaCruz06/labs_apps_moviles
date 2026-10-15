import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moviles_auth/components/auth_form_card.dart';
import 'package:moviles_auth/components/error_message.dart';
import 'package:moviles_auth/components/primary_button.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_bloc.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_event.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_state.dart';

/// Sign in form with email and password.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _validationErrorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(LoginState state) {
    if (state.status == LoginStatus.loading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _validationErrorMessage = 'Escribe tu correo y tu contraseña';
      });
      return;
    }
    setState(() {
      _validationErrorMessage = null;
    });

    context.read<LoginBloc>().add(
      LoginSubmitted(email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state.status == LoginStatus.success && state.result != null) {
                Navigator.pushReplacementNamed(
                  context,
                  '/home',
                  arguments: state.result,
                );
              }
            },
            child: BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) => AuthFormCard(
                icon: Icons.lock_person_outlined,
                title: 'Bienvenido de nuevo',
                subtitle: 'Ingresa con tu correo y tu contraseña',
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (state.status == LoginStatus.failure ||
                        _validationErrorMessage != null) ...[
                      ErrorMessage(
                        message: state.status == LoginStatus.failure
                            ? state.errorMessage ??
                                  'No fue posible iniciar sesión.'
                            : _validationErrorMessage!,
                      ),
                      const SizedBox(height: 16),
                    ],
                    PrimaryButton(
                      label: 'Iniciar sesión',
                      isLoading: state.status == LoginStatus.loading,
                      onPressed: () => _submit(state),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/register',
                        ),
                        child: const Text('¿No tienes cuenta? Regístrate'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
