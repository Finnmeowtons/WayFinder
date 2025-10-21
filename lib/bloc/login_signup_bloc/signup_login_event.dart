part of 'signup_login_bloc.dart';

sealed class SignupLoginEvent extends Equatable {
  const SignupLoginEvent();
  @override
  List<Object> get props => [];
}

// Triggered when the user enters phone number & OTP and wants to login/signup
final class SignInRequested extends SignupLoginEvent {
  final String phoneNumber;
  final String otp;
  const SignInRequested({required this.phoneNumber, required this.otp});

  @override
  List<Object> get props => [phoneNumber, otp];
}

// Triggered to confirm user after OTP verification
final class ConfirmUserRequested extends SignupLoginEvent {
  final String phoneNumber;
  const ConfirmUserRequested({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}
