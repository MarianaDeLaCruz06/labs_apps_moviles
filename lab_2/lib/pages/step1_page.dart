import 'package:flutter/material.dart';

import '../components/labeled_text_field.dart';
import '../components/primary_button.dart';
import '../components/step_header.dart';

class Step1Page extends StatelessWidget {
  const Step1Page({
    super.key,
    required this.onNameChanged,
    required this.onUsernameChanged,
    required this.onNext,
  });

  final Function(String) onNameChanged;
  final Function(String) onUsernameChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StepHeader(
            step: 1,
            title: '¿Cómo te llamas?',
            subtitle: 'Así sabremos cómo saludarte',
          ),

          const SizedBox(height: 40),

          LabeledTextField(
            label: 'Nombre completo',
            hint: 'María Alejandra Zamudio',
            onChanged: onNameChanged,
          ),

          LabeledTextField(
            label: 'Nombre de usuario',
            hint: 'alejandra.zamudio',
            icon: Icons.alternate_email,
            onChanged: onUsernameChanged,
          ),

          const Spacer(),

          PrimaryButton(
            text: 'Continuar',
            onPressed: onNext,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}