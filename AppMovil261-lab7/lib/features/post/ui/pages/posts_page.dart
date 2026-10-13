import 'package:appmovil261/features/post/ui/bloc/post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
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
      context.read<PostBloc>().add(PostSubmitEvent(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
          ));
    }
  }

  void _resetForm() {
    _titleController.clear();
    _contentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostBloc(),
      child: BlocConsumer<PostBloc, PostState>(
        listener: (context, state) {
          if (state is PostSuccessState) {
            _resetForm();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post publicado exitosamente')),
            );
          } else if (state is PostErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is PostLoadingState;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                    maxLines: 5,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Ingresa el contenido' : null,
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
