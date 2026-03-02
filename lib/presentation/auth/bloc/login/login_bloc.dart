import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/auth_remote_datasource.dart';
import '../../../../data/datasources/auth_local_datasource.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRemoteDatasource _authRemoteDatasource;

  LoginBloc(this._authRemoteDatasource) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginReset>(_onLoginReset);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    final result = await _authRemoteDatasource.login(
      event.email,
      event.password,
    );

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(LoginError(error));
    } else {
      final authResponse = result.fold((l) => null, (r) => r);
      if (authResponse != null && authResponse.success && authResponse.token != null) {
        await AuthLocalDatasource().saveAuthData(authResponse);
        emit(LoginSuccess());
      } else {
        emit(LoginError(authResponse?.message ?? 'Login gagal'));
      }
    }
  }

  void _onLoginReset(
    LoginReset event,
    Emitter<LoginState> emit,
  ) {
    emit(LoginInitial());
  }
}
