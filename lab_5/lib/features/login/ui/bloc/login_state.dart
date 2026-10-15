import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState {
  final LoginStatus status;
  final SignInResult? result;
  final String? errorMessage;

  const LoginState({
    this.status = LoginStatus.initial,
    this.result,
    this.errorMessage,
  });

  LoginState copyWith({
    LoginStatus? status,
    SignInResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearErrorMessage = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      result: clearResult ? null : result ?? this.result,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
