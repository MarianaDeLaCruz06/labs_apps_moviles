//Eventos
import 'package:appmovil261/features/auth/domain/usecases/signup_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SignupEvent {}

class SignupSubmitEvent extends SignupEvent {
  //Puedo hacer un modelo de usuario de UI
  final String username;
  final String email;
  final String password;
  SignupSubmitEvent({
    required this.username,
    required this.email,
    required this.password,
  });
}

//States
abstract class SignupState {}

class SignupIdleState extends SignupState {}

class SignupSuccessState extends SignupState {}

class SignupFailState extends SignupState {
  final String message;
  SignupFailState({required this.message});
}

class SignupLoadingState extends SignupState {}

//BloC
class SignupBloc extends Bloc<SignupEvent, SignupState> {
  //Dependencia
  final SignupUsecase _usecase = SignupUsecase(); //Es una práctica temprana

  SignupBloc() : super(SignupIdleState()) {
    //Funciones on
    on<SignupSubmitEvent>(signup);
  }

  Future<void> signup(
    SignupSubmitEvent event,
    Emitter<SignupState> emit,
  ) async {
    //Notificar que estamos cargando
    emit(SignupLoadingState());
    try {
      await _usecase.execute(event.username, event.email, event.password);
      emit(SignupSuccessState());
    } catch (e) {
      emit(SignupFailState(message: e.toString())); //Mensaje de error requerido
    }
  }
}
