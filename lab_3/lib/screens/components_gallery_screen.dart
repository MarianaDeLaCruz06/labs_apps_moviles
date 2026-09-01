import 'package:flutter/material.dart';

import '../components/app_top_bar.dart';
import '../components/highlight_card.dart';
import '../components/info_row.dart';
import '../components/labeled_text_field.dart';
import '../components/mood_button.dart';
import '../components/playlist_card.dart';
import '../components/playlist_cover.dart';
import '../components/playlist_hero.dart';
import '../components/primary_button.dart';
import '../components/profile_header.dart';
import '../components/secondary_button.dart';
import '../components/section_title.dart';
import '../components/step_header.dart';

/// The label above each demo. It is not one of the components: it only names
/// the one shown right below.
class _Nombre extends StatelessWidget {
  const _Nombre(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF1DB954),
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

/// Gallery of every component the lab gives you, so you can see them running
/// before building anything. It is not part of the app: once you register the
/// routes it stops being the initial screen.
class ComponentsGalleryScreen extends StatelessWidget {
  const ComponentsGalleryScreen({super.key});

  static const _cover = 'https://picsum.photos/id/1082/300';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Componentes'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Nombre('SectionTitle'),
            const SizedBox(height: 12),
            const SectionTitle(text: 'Basado en tus gustos'),
            const SizedBox(height: 32),

            const _Nombre('StepHeader'),
            const SizedBox(height: 12),
            const StepHeader(
              step: 1,
              title: '¿Cómo te llamas?',
              subtitle: 'Así sabremos cómo saludarte',
            ),
            const SizedBox(height: 32),

            const _Nombre('LabeledTextField'),
            const SizedBox(height: 12),
            LabeledTextField(
              label: 'Nombre completo',
              hint: 'María Alejandra Zamudio',
              onChanged: (value) {},
            ),
            LabeledTextField(
              label: 'Correo',
              hint: 'tunombre@icesi.edu.co',
              icon: Icons.alternate_email,
              onChanged: (value) {},
            ),
            LabeledTextField(
              label: 'Contraseña',
              hint: '••••••••',
              isPassword: true,
              onChanged: (value) {},
            ),
            const SizedBox(height: 12),

            const _Nombre('MoodButton'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                MoodButton(text: 'Chill', isSelected: true, onPressed: () {}),
                MoodButton(text: 'Fiesta', isSelected: false, onPressed: () {}),
                MoodButton(text: 'Enfoque', isSelected: false, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 32),

            const _Nombre('PrimaryButton'),
            const SizedBox(height: 12),
            PrimaryButton(text: 'Continuar', onPressed: () {}),
            const SizedBox(height: 12),
            PrimaryButton(
              text: 'Crear',
              icon: Icons.add,
              onPressed: () {},
            ),
            const SizedBox(height: 32),

            const _Nombre('SecondaryButton'),
            const SizedBox(height: 12),
            SecondaryButton(text: 'Previsualizar', onPressed: () {}),
            const SizedBox(height: 12),
            SecondaryButton(
              text: 'Editar perfil',
              fullWidth: true,
              onPressed: () {},
            ),
            const SizedBox(height: 32),

            const _Nombre('InfoRow'),
            const SizedBox(height: 12),
            const InfoRow(label: 'Correo', value: 'mzamudio@icesi.edu.co'),
            const InfoRow(label: 'Mood', value: 'Chill'),
            const InfoRow(label: 'Sin valor', value: ''),
            const SizedBox(height: 32),

            const _Nombre('HighlightCard'),
            const SizedBox(height: 12),
            const HighlightCard(
              title: 'Radio Karol G',
              subtitle: 'Canciones parecidas a lo que te gusta',
            ),
            const SizedBox(height: 32),

            const _Nombre('PlaylistCover'),
            const SizedBox(height: 12),
            const Row(
              children: [
                PlaylistCover(url: _cover),
                SizedBox(width: 16),
                PlaylistCover(url: '', size: 96),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'El segundo no tiene URL: así se ve el respaldo.',
              style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 13),
            ),
            const SizedBox(height: 32),

            const _Nombre('PlaylistCard'),
            const SizedBox(height: 12),
            const PlaylistCard(
              name: 'Chill Vibes Songs',
              mood: 'Chill',
              coverUrl: _cover,
            ),
            const SizedBox(height: 32),

            const _Nombre('PlaylistHero'),
            const SizedBox(height: 12),
            const PlaylistHero(
              name: 'Chill Vibes Songs',
              mood: 'Chill',
              coverUrl: _cover,
            ),
            const SizedBox(height: 32),

            const _Nombre('ProfileHeader'),
            const SizedBox(height: 12),
            const ProfileHeader(
              name: 'María Alejandra Zamudio',
              username: 'alejandra.zamudio',
            ),
            const SizedBox(height: 32),

            const _Nombre('AppTopBar'),
            const SizedBox(height: 12),
            const Text(
              'Es la barra de arriba de esta misma pantalla. Va en el appBar '
              'del Scaffold, no dentro del body.',
              style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 13),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
