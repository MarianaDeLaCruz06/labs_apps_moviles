import 'package:appmovil261/features/chat/data/repository/chat_repository_impl.dart';
import 'package:appmovil261/features/chat/domain/models/message.dart';
import 'package:appmovil261/features/chat/domain/repository/chat_repository.dart';
import 'dart:typed_data';

class SendMessageUsecase {
  final ChatRepository _repository = ChatRepositoryImpl();

  Future<void> execute(
    Message message, {
    Uint8List? imageBytes,
    String? imageFileName,
    String? imageMimeType,
  }) {
    return _repository.sendMessage(
      message,
      imageBytes: imageBytes,
      imageFileName: imageFileName,
      imageMimeType: imageMimeType,
    );
  }
}
