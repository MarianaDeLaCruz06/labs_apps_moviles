import 'dart:async';
import 'dart:typed_data';

import 'package:appmovil261/features/chat/domain/models/message.dart';
import 'package:appmovil261/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:appmovil261/features/chat/domain/usecases/watch_messages_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

abstract class ChatEvent {}

class SubscribeToMessagesEvent extends ChatEvent {
  final String conversationId;
  SubscribeToMessagesEvent(this.conversationId);
}

class SendMessageEvent extends ChatEvent {
  final String conversationId;
  final String senderId;
  final String content;
  final Uint8List? imageBytes;
  final String? imageFileName;
  final String? imageMimeType;

  SendMessageEvent({
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.imageBytes,
    this.imageFileName,
    this.imageMimeType,
  });
}

class _MessagesUpdatedEvent extends ChatEvent {
  final List<Message> messages;
  _MessagesUpdatedEvent(this.messages);
}

class _MessagesErrorEvent extends ChatEvent {
  final String message;
  _MessagesErrorEvent(this.message);
}

abstract class ChatState {}

class ChatInitialState extends ChatState {}

class ChatLoadingState extends ChatState {}

class ChatLoadedState extends ChatState {
  final List<Message> messages;
  final bool isSending;
  ChatLoadedState(this.messages, {this.isSending = false});
}

class ChatMessageSentState extends ChatLoadedState {
  ChatMessageSentState(super.messages);
}

class ChatSendErrorState extends ChatLoadedState {
  final String message;
  ChatSendErrorState(super.messages, this.message);
}

class ChatErrorState extends ChatState {
  final String message;
  ChatErrorState(this.message);
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUsecase _sendMessageUsecase = SendMessageUsecase();
  final WatchMessagesUsecase _watchMessagesUsecase = WatchMessagesUsecase();

  StreamSubscription<List<Message>>? _messagesSubscription;
  List<Message> _messages = const [];
  bool _isSending = false;

  ChatBloc() : super(ChatInitialState()) {
    on<SubscribeToMessagesEvent>((event, emit) async {
      emit(ChatLoadingState());
      await _messagesSubscription?.cancel();
      try {
        _messagesSubscription = _watchMessagesUsecase
            .execute(event.conversationId)
            .listen(
              (messages) {
                if (!isClosed) add(_MessagesUpdatedEvent(messages));
              },
              onError: (Object error) {
                if (!isClosed) add(_MessagesErrorEvent(error.toString()));
              },
            );
      } catch (error) {
        emit(ChatErrorState(error.toString()));
      }
    });

    on<_MessagesUpdatedEvent>((event, emit) {
      _messages = event.messages;
      emit(ChatLoadedState(_messages, isSending: _isSending));
    });

    on<_MessagesErrorEvent>((event, emit) {
      emit(ChatErrorState(event.message));
    });

    on<SendMessageEvent>((event, emit) async {
      if (event.content.trim().isEmpty && event.imageBytes == null) return;
      if (_isSending) return;
      _isSending = true;
      emit(ChatLoadedState(_messages, isSending: true));

      try {
        await _sendMessageUsecase.execute(
          Message(
            id: const Uuid().v4(),
            conversationId: event.conversationId,
            senderId: event.senderId,
            content: event.content.trim(),
            createdAt: DateTime.now().toUtc(),
          ),
          imageBytes: event.imageBytes,
          imageFileName: event.imageFileName,
          imageMimeType: event.imageMimeType,
        );
        _isSending = false;
        emit(ChatMessageSentState(_messages));
      } catch (error) {
        _isSending = false;
        emit(
          ChatSendErrorState(_messages, 'No se pudo enviar el mensaje: $error'),
        );
      }
    });
  }

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    await super.close();
  }
}
