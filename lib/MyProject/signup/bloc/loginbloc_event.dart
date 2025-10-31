import 'package:virmedo/MyProject/signup/modelclass/signupmodelclass.dart';

abstract class AuthEvent {}

class SignUpEvent extends AuthEvent {
  final UserModel user;
  SignUpEvent(this.user);
}
