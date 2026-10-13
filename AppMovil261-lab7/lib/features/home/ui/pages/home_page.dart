import 'package:appmovil261/features/post/ui/bloc/post_bloc.dart';
import 'package:appmovil261/features/post/ui/bloc/posts_list_bloc.dart';
import 'package:appmovil261/features/post/ui/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PostsListBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = PostsListBloc()..add(PostsListFetchEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _openCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) =>
          BlocProvider.value(value: _bloc, child: const _CreatePostModal()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        body: BlocBuilder<PostsListBloc, PostsListState>(
          builder: (context, state) {
            if (state is PostsListLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is PostsListErrorState) {
              return _FeedErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<PostsListBloc>().add(PostsListFetchEvent()),
              );
            }
            if (state is PostsListUnavailableState) {
              return const _FeedUnavailableView();
            }
            if (state is PostsListLoadedState) {
              if (state.posts.isEmpty) {
                return _FeedEmptyView(
                  onCreate: () => _openCreateModal(context),
                );
              }
              return ListView.builder(
                itemCount: state.posts.length,
                itemBuilder: (_, index) => PostCard(post: state.posts[index]),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: BlocBuilder<PostsListBloc, PostsListState>(
          builder: (context, state) {
            if (state is! PostsListLoadedState || state.posts.isEmpty) {
              return const SizedBox.shrink();
            }
            return FloatingActionButton(
              onPressed: () => _openCreateModal(context),
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}

class _FeedUnavailableView extends StatelessWidget {
  const _FeedUnavailableView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.dynamic_feed_outlined,
                  size: 72,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'No hay publicaciones disponibles',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'El Feed todavía no está configurado. Mientras tanto, '
                  'puedes seguir conversando desde la sección de Chats',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedEmptyView extends StatelessWidget {
  final VoidCallback onCreate;

  const _FeedEmptyView({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 0,
              color: colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 36,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.groups_outlined,
                        size: 56,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '¡Todavía no hay publicaciones!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Este espacio está esperando su primera historia. '
                      'Comparte una idea, experiencia o algo interesante con '
                      'la comunidad.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: onCreate,
                      icon: const Icon(Icons.add),
                      label: const Text('Crear publicación'),
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

class _FeedErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FeedErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 20),
                Text(
                  message,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreatePostModal extends StatefulWidget {
  const _CreatePostModal();

  @override
  State<_CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<_CreatePostModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<PostBloc>().add(
        PostSubmitEvent(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostBloc(),
      child: BlocConsumer<PostBloc, PostState>(
        listener: (context, state) {
          if (state is PostSuccessState) {
            context.read<PostsListBloc>().add(
              PostsListAddOptimisticEvent(state.post),
            );
            Navigator.pop(context);
          } else if (state is PostErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is PostLoadingState;
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Nuevo Post',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Ingresa un título' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(labelText: 'Contenido'),
                    maxLines: 4,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Ingresa el contenido'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _submit(context),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Publicar'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
