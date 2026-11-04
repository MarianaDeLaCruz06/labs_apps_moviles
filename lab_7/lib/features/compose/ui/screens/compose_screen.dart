import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moviles_auth/components/error_message.dart';
import 'package:moviles_auth/components/primary_button.dart';
import 'package:moviles_auth/features/avatar/domain/entities/photo_source.dart';
import 'package:moviles_auth/features/compose/ui/bloc/compose_bloc.dart';
import 'package:moviles_auth/features/compose/ui/bloc/compose_event.dart';
import 'package:moviles_auth/features/compose/ui/bloc/compose_state.dart';
import 'package:moviles_auth/theme/app_theme.dart';

/// Writes a new post with an optional photo.
/// Returns to the wall after publishing successfully.
class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});

  @override
  State<ComposeScreen> createState() {
    return _ComposeScreenState();
  }
}

class _ComposeScreenState extends State<ComposeScreen> {
  static const maxLength = 280;

  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _contentController.addListener(_updateCharacterCount);
  }

  void _updateCharacterCount() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _contentController.removeListener(_updateCharacterCount);
    _contentController.dispose();
    super.dispose();
  }

  /// Shows a menu to select the photo source.
  Future<void> _choosePhotoSource() async {
    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Agregar fotografía',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primaryDark,
                  ),
                  title: const Text('Elegir de la galería'),
                  subtitle: const Text('Seleccionar una fotografía existente'),
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

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    // If the user closes the menu, nothing changes.
    if (!mounted || source == null) return;

    // Tell ComposeBloc which source was selected.
    context.read<ComposeBloc>().add(ComposePhotoRequested(source: source));
  }

  /// Shows the selected photo or the Add photo button.
  Widget _photo(ComposeState state) {
    final photo = state.photo;

    if (photo == null) {
      return OutlinedButton.icon(
        onPressed: state.status == ComposeStatus.loading
            ? null
            : _choosePhotoSource,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Agregar foto'),
      );
    }

    return Stack(
      children: [
        Container(
          height: 280,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.lavender,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Image.memory(
            photo.bytes,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),

        Positioned(
          top: 8,
          right: 8,
          child: IconButton.filledTonal(
            onPressed: state.status == ComposeStatus.loading
                ? null
                : () {
                    context.read<ComposeBloc>().add(ComposePhotoRemoved());
                  },
            icon: const Icon(Icons.close),
            tooltip: 'Quitar foto',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final length = _contentController.text.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo post')),

      body: SafeArea(
        child: BlocListener<ComposeBloc, ComposeState>(
          listener: (context, state) {
            if (state.status == ComposeStatus.success) {
              Navigator.pop(context, true);
            }
          },

          child: BlocBuilder<ComposeBloc, ComposeState>(
            builder: (context, state) {
              final isLoading = state.status == ComposeStatus.loading;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _contentController,
                      minLines: 5,
                      maxLines: 8,
                      maxLength: maxLength,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        hintText: '¿Qué estás pensando?',
                        counterText: '',
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '$length/$maxLength',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: length > maxLength
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Photo preview or button to select a photo.
                    _photo(state),

                    const SizedBox(height: 16),

                    if (state.status == ComposeStatus.failure &&
                        state.errorMessage != null) ...[
                      ErrorMessage(message: state.errorMessage!),
                      const SizedBox(height: 16),
                    ],

                    PrimaryButton(
                      label: 'Publicar',
                      isLoading: isLoading,
                      onPressed: () {
                        if (isLoading) return;

                        context.read<ComposeBloc>().add(
                          ComposeSubmitted(_contentController.text),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
