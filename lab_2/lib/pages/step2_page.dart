import 'package:flutter/material.dart';

import '../components/labeled_text_field.dart';
import '../components/mood_button.dart';
import '../components/primary_button.dart';
import '../components/step_header.dart';

class Step2Page extends StatefulWidget {
  const Step2Page({
    super.key,
    required this.onArtistChanged,
    required this.onMoodChanged,
    required this.onNext,
  });

  final Function(String) onArtistChanged;
  final Function(String) onMoodChanged;
  final VoidCallback onNext;

  @override
  State<Step2Page> createState() => _Step2PageState();
}

class _Step2PageState extends State<Step2Page> {
  String selectedMood = '';

  void selectMood(String mood) {
    setState(() {
      selectedMood = mood;
    });

    widget.onMoodChanged(mood);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StepHeader(
            step: 2,
            title: '¿Qué te mueve?',
            subtitle: 'Con esto armamos tus recomendaciones',
          ),

          const SizedBox(height: 40),

          LabeledTextField(
            label: 'Artista favorito',
            hint: 'Eladio Carrion',
            onChanged: widget.onArtistChanged,
          ),

          const SizedBox(height: 4),

          const Text(
            'Tu mood',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              MoodButton(
                text: 'Chill',
                isSelected: selectedMood == 'Chill',
                onPressed: () => selectMood('Chill'),
              ),

              MoodButton(
                text: 'Fiesta',
                isSelected: selectedMood == 'Fiesta',
                onPressed: () => selectMood('Fiesta'),
              ),

              MoodButton(
                text: 'Enfoque',
                isSelected: selectedMood == 'Enfoque',
                onPressed: () => selectMood('Enfoque'),
              ),
            ],
          ),

          const Spacer(),

          PrimaryButton(
            text: 'Continuar',
            onPressed: widget.onNext,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}