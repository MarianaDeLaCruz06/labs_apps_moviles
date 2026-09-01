import 'package:flutter/material.dart';

import '../components/labeled_text_field.dart';
import '../components/primary_button.dart';
import '../models/music_profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool loaded = false;

  late MusicProfile profile;

  String name = '';
  String username = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!loaded) {
      profile =
          ModalRoute.of(context)!.settings.arguments as MusicProfile;

      name = profile.fullName;
      username = profile.username;

      loaded = true;
    }
  }

  void saveProfile() {
    profile.fullName = name;
    profile.username = username;

    Navigator.pop(
      context,
      profile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      LabeledTextField(
                        label: 'Nombre completo',
                        hint: profile.fullName,
                        onChanged: (value) {
                          name = value;
                        },
                      ),

                      LabeledTextField(
                        label: 'Nombre de usuario',
                        hint: profile.username,
                        icon: Icons.alternate_email,
                        onChanged: (value) {
                          username = value;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              PrimaryButton(
                text: 'Guardar',
                onPressed: saveProfile,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}