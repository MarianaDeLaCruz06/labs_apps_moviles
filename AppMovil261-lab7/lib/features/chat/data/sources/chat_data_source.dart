import 'package:appmovil261/features/chat/domain/models/conversation.dart';
import 'package:appmovil261/features/chat/domain/models/message.dart';
import 'package:appmovil261/features/profile/domain/model/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class ChatDataSource {
  static const _chatImagesBucket = 'chat-images';
  final _client = Supabase.instance.client;

  Future<List<Profile>> getProfiles() async {
    final response = await _client.from('profiles').select().order('name');
    return response.map((e) => Profile.fromJson(e)).toList();
  }

  Future<Conversation> getOrCreateConversation(
    String currentUserId,
    String otherUserId,
  ) async {
    // Busca si ya existe la conversación en cualquier dirección
    final existing = await _client
        .from('conversations')
        .select()
        .or(
          'and(profile1_id.eq.$currentUserId,profile2_id.eq.$otherUserId),and(profile1_id.eq.$otherUserId,profile2_id.eq.$currentUserId)',
        )
        .maybeSingle();

    if (existing != null) {
      return Conversation.fromJson(existing, currentUserId);
    }

    final created = await _client
        .from('conversations')
        .insert({'profile1_id': currentUserId, 'profile2_id': otherUserId})
        .select()
        .single();

    return Conversation.fromJson(created, currentUserId);
  }

  Future<void> sendMessage(
    Message message, {
    Uint8List? imageBytes,
    String? imageFileName,
    String? imageMimeType,
  }) async {
    String? uploadedPath;

    try {
      if (imageBytes != null) {
        if (imageBytes.lengthInBytes > 10 * 1024 * 1024) {
          throw ArgumentError('La imagen no puede superar los 10 MB.');
        }
        final extension = _safeExtension(imageFileName, imageMimeType);
        uploadedPath =
            '${message.conversationId}/${message.senderId}/${const Uuid().v4()}.$extension';

        await _client.storage
            .from(_chatImagesBucket)
            .uploadBinary(
              uploadedPath,
              imageBytes,
              fileOptions: FileOptions(
                contentType: _contentType(extension),
                upsert: false,
              ),
            );
      }

      final row = message.toJson();
      if (uploadedPath != null) row['image_path'] = uploadedPath;
      await _client.from('messages').insert(row);
    } catch (_) {
      if (uploadedPath != null) {
        try {
          await _client.storage.from(_chatImagesBucket).remove([uploadedPath]);
        } catch (_) {
          // The original upload/insert error is more useful to the caller.
        }
      }
      rethrow;
    }
  }

  String _safeExtension(String? fileName, String? mimeType) {
    final nameExtension = fileName?.split('.').last.toLowerCase();
    const allowed = {'jpg', 'jpeg', 'png', 'gif', 'webp'};
    if (nameExtension != null && allowed.contains(nameExtension)) {
      return nameExtension;
    }

    return switch (mimeType) {
      'image/png' => 'png',
      'image/gif' => 'gif',
      'image/webp' => 'webp',
      'image/jpeg' => 'jpg',
      _ => throw ArgumentError(
        'Formato de imagen no compatible. Usa JPG, PNG, GIF o WebP.',
      ),
    };
  }

  String _contentType(String extension) => switch (extension) {
    'png' => 'image/png',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };

  // Realtime: escucha nuevos mensajes de la conversación
  Stream<List<Message>> watchMessages(String conversationId) {
    // Carga inicial + actualizaciones en tiempo real con StreamController
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false)
        .asyncMap((rows) async {
          final messages = rows.map(Message.fromJson).toList();
          return Future.wait(
            messages.map((message) async {
              if (message.imagePath == null) return message;

              final signedUrl = await _client.storage
                  .from(_chatImagesBucket)
                  .createSignedUrl(message.imagePath!, 3600);
              return message.copyWith(imageUrl: signedUrl);
            }),
          );
        });
  }
}
