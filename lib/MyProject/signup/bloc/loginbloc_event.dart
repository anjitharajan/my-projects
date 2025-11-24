import 'package:virmedo/MyProject/signup/modelclass/signupmodelclass.dart';

abstract class AuthEvent {}

class SignUpEvent extends AuthEvent {
  final UserModel user;
  SignUpEvent(this.user);
}

class LoginEvent extends AuthEvent {
  final String emailOrCode;
  final String password;
  final String role; //<<<<<---------"Admin", "Hospital", "Patient"

  LoginEvent({
    required this.emailOrCode,
    required this.password,
    required this.role,
  });
}