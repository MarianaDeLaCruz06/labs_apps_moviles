import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moviles_auth/features/avatar/domain/entities/photo_source.dart';
import 'package:moviles_auth/features/home/ui/bloc/feed_bloc.dart';
import 'package:moviles_auth/features/home/ui/bloc/feed_event.dart';
import 'package:moviles_auth/features/home/ui/bloc/feed_state.dart';
import 'package:moviles_auth/features/home/ui/pages/feed_page.dart';
import 'package:moviles_auth/features/home/ui/pages/profile_page.dart';
import 'package:moviles_auth/theme/app_theme.dart';
import 'package:moviles_auth/features/posts/domain/entities/post.dart';

/// Hosts FeedPage and ProfilePage behind a BottomNavigationBar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();

    final bloc = context.read<FeedBloc>();
    bloc.add(ProfileRequested());
    bloc.add(FeedStarted());
  }

  Future<void> _openCompose() async {
    final published = await Navigator.pushNamed(context, '/compose');

    if (published == true && mounted) {
      context.read<FeedBloc>().add(FeedStarted());
    }
  }

  Future<void> _chooseAvatarSource() async {
    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cambiar foto de perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primaryDark,
                  ),
                  title: const Text('Elegir de la galería'),
                  subtitle: const Text('Seleccionar una foto existente'),
                  onTap: () {
                    Navigator.pop(sheetContext, PhotoSource.gallery);
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primaryDark,
                  ),
                  title: const Text('Tomar una foto'),
                  subtitle: const Text('Abrir la cámara del dispositivo'),
                  onTap: () {
                    Navigator.pop(sheetContext, PhotoSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || source == null) return;

    context.read<FeedBloc>().add(AvatarChangeRequested(source: source));
  }

  Future<void> _confirmDelete(Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: const Text(
          'Esta acción eliminará la publicación y su imagen asociada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    context.read<FeedBloc>().add(FeedPostDeleteRequested(post));
  }

  Widget _page(FeedState state) {
    final bloc = context.read<FeedBloc>();

    if (_index == 1) {
      final profile = state.profile;

      if (profile == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return ProfilePage(
        profile: profile,
        posts: state.myPosts,
        isUploading: state.avatarStatus == AvatarStatus.uploading,
        onChangePhoto: _chooseAvatarSource,
        onLike: (post) => bloc.add(FeedLikeToggled(post)),
        onSignOut: () => bloc.add(SignOutRequested()),
        onRemovePhoto: () => bloc.add(AvatarRemoveRequested()),
        onDelete: _confirmDelete,
      );
    }

    return FeedPage(
      posts: state.posts,
      hasMore: state.hasMore,
      isLoading: state.status == FeedStatus.loading,
      onLoadMore: () => bloc.add(FeedMoreRequested()),
      onLike: (post) => bloc.add(FeedLikeToggled(post)),
      onDelete: _confirmDelete,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FeedBloc, FeedState>(
          listenWhen: (previous, current) =>
              !previous.signedOut && current.signedOut,
          listener: (context, state) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          },
        ),
        BlocListener<FeedBloc, FeedState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == FeedStatus.failure,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Algo falló')),
            );
          },
        ),
        BlocListener<FeedBloc, FeedState>(
          listenWhen: (previous, current) =>
              previous.avatarStatus != current.avatarStatus &&
              current.avatarStatus == AvatarStatus.failure,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Algo falló')),
            );
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text(_index == 0 ? 'Muro' : 'Perfil')),
        body: BlocBuilder<FeedBloc, FeedState>(
          builder: (context, state) => _page(state),
        ),
        floatingActionButton: _index == 0
            ? FloatingActionButton(
                onPressed: _openCompose,
                child: const Icon(Icons.edit),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (index) {
            setState(() => _index = index);
          },
          selectedItemColor: AppColors.primaryDark,
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Muro',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
