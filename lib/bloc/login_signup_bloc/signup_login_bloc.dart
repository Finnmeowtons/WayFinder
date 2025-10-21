import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:way_finders/repository/auth_repository.dart';

part 'signup_login_event.dart';
part 'signup_login_state.dart';

class SignupLoginBloc extends Bloc<SignupLoginEvent, SignupLoginState> {
  final AuthRepository authRepository;

  SignupLoginBloc(this.authRepository) : super(SignupLoginInitial()) {
    on<SignInRequested>((event, emit) async {
      emit(SignupLoginLoading());
      try {
        final response = await authRepository.signIn(event.phoneNumber, event.otp);
        // Assuming response contains a message like "OTP sent"
        emit(OTPRequested(message: response['message'] ?? 'OTP sent'));
      } catch (e) {
        emit(SignupLoginError(error: e.toString()));
      }
    });

    on<ConfirmUserRequested>((event, emit) async {
      emit(SignupLoginLoading());
      try {
        final response = await authRepository.confirmUser(event.phoneNumber);
        emit(UserConfirmed(token: response['token']));

      } catch (e) {
        emit(SignupLoginError(error: e.toString()));
      }
    });
  }
}

