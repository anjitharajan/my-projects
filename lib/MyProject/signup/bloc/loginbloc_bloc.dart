import 'package:bloc/bloc.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:virmedo/MyProject/signup/bloc/loginbloc_event.dart';
import 'package:virmedo/MyProject/signup/bloc/loginbloc_state.dart';
import 'package:virmedo/MyProject/signup/modelclass/signupmodelclass.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final Uuid _uuid = Uuid();

  AuthBloc() : super(AuthInitial()) {
    on<SignUpEvent>(_onSignUp);
    on<LoginEvent>(_onLogin);
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final user = event.user;

    try {
      if (user.email == null || user.email!.isEmpty) {
        emit(AuthFailure("Email cannot be empty"));
        return;
      }
      if (user.password == null || user.password!.isEmpty) {
        emit(AuthFailure("Password cannot be empty"));
        return;
      }

      if (!user.email!.contains("@")) {
        emit(AuthFailure("Invalid Email Address"));
        return;
      }

      final email = user.email!.trim().toLowerCase();

      if (user.role == "Admin") {
        final existingSnapshot = await dbRef
            .child('admins')
            .orderByChild('email')
            .equalTo(user.email)
            .get();

        if (existingSnapshot.exists) {
          emit(AuthFailure("Admin with this email already exists."));
          return;
        }
      }

      if (user.role == "Hospital") {
        try {
          final existingSnapshot = await dbRef
              .child('hospitals')
              .orderByChild('code')
              .equalTo(user.adminCode)
              .get();

          if (existingSnapshot.exists) {
            final hospitalKey = existingSnapshot.children.first.key!;

            await dbRef.child('hospitals/$hospitalKey').update({
              "name": user.name ?? "No Name",
              "email": user.email,
              "password": user.password,
              "address": user.address ?? "No address",
              "contact": user.contact ?? "No contact",
              "linked": true,
              "updatedAt": DateTime.now().toIso8601String(),
            });
            emit(
              AuthSuccess(
                UserModel(
                  id: hospitalKey,
                  name: user.name,
                  email: user.email,
                  password: user.password,
                  role: "Hospital",
                ),
              ),
            );
          } else {
            emit(AuthFailure("Invalid Hospital Code. Please contact admin."));
          }
        } catch (e) {
          emit(AuthFailure("Error linking hospital: $e"));
        }
        return;
      }

      if (user.role == "Doctor") {
        final existingSnapshot = await dbRef
            .child('doctors')
            .orderByChild('email')
            .equalTo(email)
            .get();

        if (existingSnapshot.exists) {
          emit(AuthFailure("Doctor with this email already exists."));
          return;
        }
      }

      final uid = _uuid.v4();
      final newUser = UserModel(
        id: uid,
        name: user.name ?? "No Name",
        email: user.email,
        password: user.password,
        role: user.role ?? "Patient",
        address: user.address,
        adminCode: user.adminCode,
        image: user.image ?? "https://via.placeholder.com/400",
      );

      if (user.role == "Hospital") {
        try {
          final existingSnapshot = await dbRef
              .child('hospitals')
              .orderByChild('code')
              .equalTo(user.adminCode)
              .get();

          if (existingSnapshot.exists) {
            final hospitalKey = existingSnapshot.children.first.key!;

            await dbRef.child('hospitals/$hospitalKey').update({
              "name": user.name ?? "No Name",
              "email": user.email,
              "password": user.password,
              "address": user.address ?? "No address",
              "contact": user.contact ?? "No contact",
              "linked": true,
              "role": "Hospital",
              "updatedAt": DateTime.now().toIso8601String(),
            });

            emit(
              AuthSuccess(
                UserModel(
                  id: hospitalKey,
                  name: user.name,
                  email: user.email,
                  password: user.password,
                  role: "Hospital",
                ),
              ),
            );
          } else {
            emit(AuthFailure("Invalid Hospital Code. Please contact admin."));
          }
        } catch (e) {
          emit(AuthFailure("Error linking hospital: $e"));
        }
        return;
      }

      if (user.role == "Doctor") {
        final doctorSnapshot = await dbRef
            .child('doctors')
            .orderByChild('email')
            .equalTo(user.email)
            .get();

        if (doctorSnapshot.exists) {
          emit(AuthFailure("A doctor with this email already exists."));
          return;
        }
        if (user.adminCode == null || user.adminCode!.isEmpty) {
          emit(AuthFailure("Hospital Code is required for Doctor Signup"));
          return;
        }

        final hospitalSnapshot = await dbRef
            .child('hospitals')
            .orderByChild('code')
            .equalTo(user.adminCode)
            .get();

        if (!hospitalSnapshot.exists) {
          emit(AuthFailure("Invalid Hospital Code. Contact Hospital Admin."));
          return;
        }

        final hospitalKey = hospitalSnapshot.children.first.key!;
        final hospitalData = Map<String, dynamic>.from(
          hospitalSnapshot.children.first.value as Map,
        );
        final hospitalName = hospitalData["name"] ?? "Unknown Hospital";

        final doctorData = {
          ...newUser.toMap(),
          "hospitalName": hospitalName,
          "hospitalId": hospitalKey,
          "hospitalCode": user.adminCode,
          "createdAt": DateTime.now().toIso8601String(),
        };

        final signedUpDoctor = UserModel(
          id: uid,
          name: newUser.name,
          email: newUser.email,
          password: newUser.password,
          role: newUser.role,
          hospitalId: hospitalKey,
          hospitalName: hospitalName,
          adminCode: user.adminCode,
          image: newUser.image,
        );

  await dbRef.child("doctors/$uid").set(doctorData);
await dbRef.child("hospitals/$hospitalKey/doctors/$uid").set(doctorData);

emit(AuthSuccess(signedUpDoctor));
return;

      }

      String node = user.role == "Admin"
          ? "admins"
          : (user.role == "Hospital"
                ? "hospitals"
                : (user.role == "Doctor" ? "doctors" : "users"));

      
      await dbRef.child("$node/$uid").set(newUser.toMap());

      emit(AuthSuccess(newUser));
    } catch (e, stackTrace) {
      print("DATABASE SIGNUP ERROR: $e");
      print(stackTrace);
      emit(AuthFailure("Unexpected Error: $e"));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final node = event.role == "Admin"
          ? "admins"
          : event.role == "Hospital"
          ? "hospitals"
          : event.role == "Doctor"
          ? "doctors"
          : "patients";

      final snapshot = await dbRef.child(node).get();

      if (!snapshot.exists) {
        emit(AuthFailure("No ${event.role} data found."));
        return;
      }

      Map data = snapshot.value as Map;
      bool found = false;
      UserModel? loggedInUser;

      data.forEach((key, value) {
        final userData = Map<String, dynamic>.from(value);

        final match = event.role == "Hospital"
            ? userData["code"] == event.emailOrCode
            : (userData["email"]?.toString().toLowerCase() ==
                  event.emailOrCode.toLowerCase());

        if (match && userData["password"] == event.password) {
          found = true;
          loggedInUser = UserModel.fromMap({
            ...userData,
            "role": userData["role"] ?? event.role,
          });
        }
      });

      if (found && loggedInUser != null) {
        emit(AuthSuccess(loggedInUser!));
      } else {
        emit(AuthFailure("Invalid ${event.role} credentials."));
      }
    } catch (e) {
      emit(AuthFailure("Login failed: $e"));
    }
  }
}
