import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_event.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInUseCase signInUseCase;

  LoginBloc({required this.signInUseCase}) : super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(
      state.copyWith(
        status: LoginStatus.loading,
        clearResult: true,
        clearErrorMessage: true,
      ),
    );

    try {
      final result = await signInUseCase(
        email: event.email,
        password: event.password,
      );
      emit(
        state.copyWith(
          status: LoginStatus.success,
          result: result,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: error.toString(),
          clearResult: true,
        ),
      );
    }
  }
}
