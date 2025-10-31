import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:virmedo/MyProject/signup/bloc/loginbloc_event.dart';
import 'package:virmedo/MyProject/signup/bloc/loginbloc_state.dart';
import 'package:virmedo/MyProject/signup/modelclass/signupmodelclass.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  AuthBloc() : super(AuthInitial()) {
    on<SignUpEvent>(_onSignUp);
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final user = event.user;

    try {
      if (user.email == null ||
          user.email!.isEmpty ||
          user.password == null ||
          user.password!.isEmpty) {
        emit(AuthFailure("Email and Password cannot be empty"));
        return;
      }

      if (!user.email!.contains("@")) {
        emit(AuthFailure("Invalid Email Address"));
        return;
      }

      if (user.role == "Admin" && user.adminCode != "111") {
        emit(AuthFailure("Invalid Admin Code"));
        return;
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: user.email!,
        password: user.password!,
      );

      final uid = credential.user!.uid;

      final newUser = UserModel(
        id: uid,
        name: user.name ?? "No Name",
        email: user.email,
        password: user.password,
        role: user.role,
        address: user.address,
        adminCode: user.adminCode,
        image: user.image ?? "https://via.placeholder.com/400",
      );

      String node = user.role == "Hospital"
          ? "hospitals"
          : user.role == "Admin"
          ? "admins"
          : "patients";

      await dbRef.child("$node/$uid").set(newUser.toMap());
      emit(AuthSuccess(newUser));
    } on FirebaseAuthException catch (e) {
      print("FIREBASE AUTH ERROR: ${e.code} - ${e.message}");
      emit(AuthFailure(e.message ?? "Authentication Failed"));
    } catch (e, stackTrace) {
      print("UNEXPECTED SIGNUP ERROR: $e");
      print(stackTrace);
      emit(AuthFailure("Unexpected Error: $e"));
    }
  }
}
