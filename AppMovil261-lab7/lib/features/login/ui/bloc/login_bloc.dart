import 'package:appmovil261/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class LoginEvent {}

class LoginSubmitEvent extends LoginEvent {
  final String email;
  final String password;
  LoginSubmitEvent({required this.email, required this.password});
}

// States
abstract class LoginState {}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessState extends LoginState {}

class LoginFailState extends LoginState {
  final String message;
  LoginFailState(this.message);
}

// BLoC
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginUsecase loginUsecase = LoginUsecase();

  LoginBloc() : super(LoginInitialState()) {
    on<LoginSubmitEvent>((event, emit) async {
      emit(LoginLoadingState());
      try {
        await loginUsecase.execute(event.email, event.password);
        emit(LoginSuccessState());
      } catch (e) {
        emit(LoginFailState(e.toString()));
      }
    });
  }
}
