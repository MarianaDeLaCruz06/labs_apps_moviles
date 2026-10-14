import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_event.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final SignUpUseCase signUpUseCase;

  RegisterBloc({required this.signUpUseCase}) : super(const RegisterState()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: RegisterStatus.loading));

    try {
      final profile = await signUpUseCase(
        username: event.username,
        fullName: event.fullName,
        email: event.email,
        password: event.password,
      );

      emit(state.copyWith(status: RegisterStatus.success, profile: profile));
    } catch (error) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
