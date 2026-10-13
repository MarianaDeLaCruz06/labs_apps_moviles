import 'package:appmovil261/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ProfileEvent {}

class ProfileLogoutEvent extends ProfileEvent {}

// States
abstract class ProfileState {}

class ProfileInitialState extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileLogoutSuccessState extends ProfileState {}

class ProfileErrorState extends ProfileState {
  final String message;
  ProfileErrorState(this.message);
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final LogoutUsecase _logoutUsecase = LogoutUsecase();

  ProfileBloc() : super(ProfileInitialState()) {
    on<ProfileLogoutEvent>((event, emit) async {
      emit(ProfileLoadingState());
      try {
        await _logoutUsecase.execute();
        emit(ProfileLogoutSuccessState());
      } catch (e) {
        emit(ProfileErrorState(e.toString()));
      }
    });
  }
}
