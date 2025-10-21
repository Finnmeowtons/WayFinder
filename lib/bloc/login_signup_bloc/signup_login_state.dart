part of 'signup_login_bloc.dart';

sealed class SignupLoginState extends Equatable {
  const SignupLoginState();

  @override
  List<Object> get props => [];
}

// Initial state
final class SignupLoginInitial extends SignupLoginState {}

// Loading state
final class SignupLoginLoading extends SignupLoginState {}

// When OTP is sent successfully
final class OTPRequested extends SignupLoginState {
  final String message;
  const OTPRequested({required this.message});

  @override
  List<Object> get props => [message];
}

// When user is confirmed and token is received
final class UserConfirmed extends SignupLoginState {
  final String token;
  const UserConfirmed({required this.token});

  @override
  List<Object> get props => [token];
}

// When an error occurs
final class SignupLoginError extends SignupLoginState {
  final String error;
  const SignupLoginError({required this.error});


  @override
  List<Object> get props => [error];
}
