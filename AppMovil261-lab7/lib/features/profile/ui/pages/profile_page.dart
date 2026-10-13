import 'package:appmovil261/features/profile/ui/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final email =
        Supabase.instance.client.auth.currentUser?.email ?? 'Sin sesión';

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLogoutSuccessState) {
          Navigator.pushReplacementNamed(context, '/login');
        } else if (state is ProfileErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          const CircleAvatar(
            radius: 90,
            child: Icon(Icons.person, size: 128),
          ),
          const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cámara'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(email, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoadingState) {
                  return const CircularProgressIndicator();
                }
                return ElevatedButton.icon(
                  onPressed: () {
                    context.read<ProfileBloc>().add(ProfileLogoutEvent());
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                );
              },
            ),
          ],
        ),
    );
  }
}

