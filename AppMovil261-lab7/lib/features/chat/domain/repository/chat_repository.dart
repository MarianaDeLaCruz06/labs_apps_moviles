import 'package:appmovil261/features/chat/domain/models/conversation.dart';
import 'package:appmovil261/features/chat/domain/models/message.dart';
import 'package:appmovil261/features/profile/domain/model/profile.dart';
import 'dart:typed_data';

abstract class ChatRepository {
  Future<List<Profile>> getProfiles();
  Future<Conversation> getOrCreateConversation(
    String currentUserId,
    String otherUserId,
  );
  Future<void> sendMessage(
    Message message, {
    Uint8List? imageBytes,
    String? imageFileName,
    String? imageMimeType,
  });
  Stream<List<Message>> watchMessages(String conversationId);
}
