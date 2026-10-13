import 'package:appmovil261/features/chat/domain/models/conversation.dart';
import 'package:appmovil261/features/chat/domain/usecases/get_or_create_conversation_usecase.dart';
import 'package:appmovil261/features/chat/domain/usecases/get_profiles_usecase.dart';
import 'package:appmovil261/features/profile/domain/model/profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class UsersEvent {}

class LoadUsersEvent extends UsersEvent {
  LoadUsersEvent();
}

class SelectUserEvent extends UsersEvent {
  final String currentUserId;
  final Profile otherUser;
  SelectUserEvent(this.currentUserId, this.otherUser);
}

// States
abstract class UsersState {}

class UsersInitialState extends UsersState {}

class UsersLoadingState extends UsersState {}

class UsersLoadedState extends UsersState {
  final List<Profile> users;
  UsersLoadedState(this.users);
}

class UsersErrorState extends UsersState {
  final String message;
  UsersErrorState(this.message);
}

class NavigateToChatState extends UsersState {
  final String conversationId;
  final String otherUserName;
  NavigateToChatState(this.conversationId, this.otherUserName);
}

// BLoC
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetProfilesUsecase _getProfilesUsecase = GetProfilesUsecase();
  final GetOrCreateConversationUsecase _getOrCreateConversationUsecase =
      GetOrCreateConversationUsecase();

  UsersBloc() : super(UsersInitialState()) {
    //funciones on
    on<LoadUsersEvent>((event, emit) async {
      emit(UsersLoadingState());
      //Cargar los usuarios
      var profiles = await _getProfilesUsecase.execute();
      emit(UsersLoadedState(profiles));
    });

    on<SelectUserEvent>((event, emit) async {
      //Crear la conversacion u obtenerla
      Conversation conversation = await _getOrCreateConversationUsecase.execute(
        event.currentUserId,
        event.otherUser.id,
      );
      emit(NavigateToChatState(conversation.id, event.otherUser.name));
    });
  }
}
