import 'dart:typed_data';

import 'package:appmovil261/features/chat/ui/bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String otherUserName;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.otherUserName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _selectedImageMimeType;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = picked.name;
        _selectedImageMimeType = picked.mimeType;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo seleccionar la imagen: $error')),
      );
    }
  }

  void _send(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un mensaje o selecciona una imagen'),
        ),
      );
      return;
    }

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para enviar mensajes'),
        ),
      );
      return;
    }

    context.read<ChatBloc>().add(
      SendMessageEvent(
        conversationId: widget.conversationId,
        senderId: currentUser.id,
        content: text,
        imageBytes: _selectedImageBytes,
        imageFileName: _selectedImageName,
        imageMimeType: _selectedImageMimeType,
      ),
    );
  }

  void _clearComposer() {
    _controller.clear();
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
      _selectedImageMimeType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ChatBloc()..add(SubscribeToMessagesEvent(widget.conversationId)),
      child: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatMessageSentState) {
            _clearComposer();
          } else if (state is ChatSendErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: Text(widget.otherUserName)),
          body: Column(
            children: [
              const Expanded(child: _MessageList()),
              if (_selectedImageBytes != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: Image.memory(
                            _selectedImageBytes!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton.filled(
                          tooltip: 'Quitar imagen',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _selectedImageBytes = null;
                              _selectedImageName = null;
                              _selectedImageMimeType = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              BlocBuilder<ChatBloc, ChatState>(
                buildWhen: (previous, current) {
                  final wasSending =
                      previous is ChatLoadedState && previous.isSending;
                  final isSending =
                      current is ChatLoadedState && current.isSending;
                  return wasSending != isSending;
                },
                builder: (context, state) => _InputBar(
                  controller: _controller,
                  onSend: _send,
                  onPickImage: _pickImage,
                  isSending: state is ChatLoadedState && state.isSending,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList();

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ChatErrorState) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error: ${state.message}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (state is ChatLoadedState) {
          if (state.messages.isEmpty) {
            return const Center(
              child: Text(
                'No hay mensajes todavía.\n¡Envía el primero!',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              return _MessageBubble(
                content: message.content,
                imageUrl: message.imageUrl,
                isMe: message.senderId == currentUserId,
              );
            },
          );
        }
        return const Center(child: Text('Cargando conversación...'));
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String content;
  final String? imageUrl;
  final bool isMe;

  const _MessageBubble({
    required this.content,
    required this.imageUrl,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl!,
                  width: 280,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const SizedBox(
                          height: 160,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                  errorBuilder: (_, _, _) => const SizedBox(
                    height: 120,
                    child: Center(child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
              ),
            if (imageUrl != null && content.isNotEmpty)
              const SizedBox(height: 8),
            if (content.isNotEmpty)
              Text(
                content,
                style: TextStyle(
                  color: isMe ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(BuildContext) onSend;
  final VoidCallback onPickImage;
  final bool isSending;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onPickImage,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: IconButton(
                tooltip: 'Seleccionar imagen',
                icon: const Icon(Icons.photo_library_outlined),
                onPressed: isSending ? null : onPickImage,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isSending,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => onSend(context),
              ),
            ),
            const SizedBox(width: 8),
            if (isSending)
              const Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton.filled(
                tooltip: 'Enviar mensaje',
                icon: const Icon(Icons.send),
                onPressed: () => onSend(context),
              ),
          ],
        ),
      ),
    );
  }
}
