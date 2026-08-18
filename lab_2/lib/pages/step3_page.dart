import 'package:flutter/material.dart';

import '../components/labeled_text_field.dart';
import '../components/playlist_cover.dart';
import '../components/primary_button.dart';
import '../components/secondary_button.dart';
import '../components/step_header.dart';

class Step3Page extends StatefulWidget {
  const Step3Page({
    super.key,
    required this.onPlaylistChanged,
    required this.onCoverChanged,
    required this.onNext,
  });

  final Function(String) onPlaylistChanged;
  final Function(String) onCoverChanged;
  final VoidCallback onNext;

  @override
  State<Step3Page> createState() => _Step3PageState();
}

class _Step3PageState extends State<Step3Page> {
  String coverUrl = '';
  String previewUrl = '';

  void previewCover() {
    setState(() {
      previewUrl = coverUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StepHeader(
            step: 3,
            title: 'Tu primera playlist',
            subtitle: 'Dale un nombre y una portada',
          ),

          const SizedBox(height: 36),

          LabeledTextField(
            label: 'Nombre de la playlist',
            hint: 'Mi mix de estudio',
            onChanged: widget.onPlaylistChanged,
          ),

          LabeledTextField(
            label: 'URL de la portada',
            hint: 'https://picsum.photos/300',
            icon: Icons.link,
            onChanged: (value) {
              coverUrl = value;
              widget.onCoverChanged(value);
            },
          ),

          SecondaryButton(
            text: 'Previsualizar',
            onPressed: previewCover,
          ),

          const SizedBox(height: 24),

          Center(
            child: PlaylistCover(
              url: previewUrl,
              size: 180,
            ),
          ),

          const SizedBox(height: 36),

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