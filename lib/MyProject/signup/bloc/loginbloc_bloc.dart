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

  //.........................................................\\
  //---------------------- sign up logic---------------------\\
  //.........................................................\\

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final user = event.user;
    try {
      //--------------------Validate field-----------------------\\

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

      //----------------------------Admin Signup----------------------------\\
      if (user.role == "Admin") {
        final existingSnapshot = await dbRef
            .child('admins')
            .orderByChild('email')
            .equalTo(email)
            .get();

        if (existingSnapshot.exists) {
          emit(AuthFailure("Admin with this email already exists."));
          return;
        }

        final uid = _uuid.v4();
        final newAdmin = UserModel(
          id: uid,
          name: user.name ?? "No Name",
          email: email,
          password: user.password,
          role: "Admin",
        );

        await dbRef.child("admins/$uid").set(newAdmin.toMap());
        emit(AuthSuccess(newAdmin));
        return;
      }

      //----------------------------------Hospital Signup----------------------------\\

      if (user.role == "Hospital") {
        final hospitalSnapshot = await dbRef
            .child('hospitals')
            .orderByChild('code')
            .equalTo(user.adminCode)
            .get();

        if (hospitalSnapshot.exists) {
          final hospitalKey = hospitalSnapshot.children.first.key!;
          await dbRef.child('hospitals/$hospitalKey').update({
           // "name": user.name ?? "No Name",
            "email": email,
           "password": user.password,
           // "address": user.address ?? "No address",
          //  "contact": user.contact ?? "No contact",
            "linked": true,
            "role": "Hospital",
            "updatedAt": DateTime.now().toIso8601String(),
          });

          emit(
            AuthSuccess(
              UserModel(
                id: hospitalKey,
                name: user.name,
                email: email,
                password: user.password,
                role: "Hospital",
                address: user.address,
                contact: user.contact,
              ),
            ),
          );
        } else {
          emit(AuthFailure("Invalid Hospital Code. Please contact admin."));
        }
        return;
      }

      //----------------------------------user Signup----------------------------\\

      final uid = _uuid.v4();
      final newUser = UserModel(
        id: uid,
        name: user.name ?? "No Name",
        email: email,
        password: user.password,
        role: user.role ?? "Patient",
        address: user.address,
        adminCode: user.adminCode,
        image: user.image ?? "https://via.placeholder.com/400",
      );

      await dbRef.child("users/$uid").set(newUser.toMap());
      emit(AuthSuccess(newUser));
    } catch (e, stackTrace) {
      print("DATABASE SIGNUP ERROR: $e");
      print(stackTrace);

      if (e.toString().contains('index-not-defined')) {
        emit(AuthFailure("Please contact admin — database index missing."));
      } else {
        emit(AuthFailure("Unexpected Error: $e"));
      }
    }
  }

  //.........................................................\\
  //---------------------- login logic---------------------\\
  //.........................................................\\

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      //-----------------Normalize role text--------------------\\
      final normalizedRole = event.role.trim();
      final roleFixed =
          normalizedRole[0].toUpperCase() +
          normalizedRole.substring(1).toLowerCase();

      print(" Login Attempt → Role: $roleFixed");

      //----------------------------------doctor login ----------------------------\\
      if (roleFixed == "Doctor") {
        final email = event.emailOrCode.trim().toLowerCase();
        final password = event.password;
        //----------------Search doctor inside all hospitals--------------\\
        final hospitalsSnap = await dbRef.child("hospitals").get();

        Map<String, dynamic>? doctorData;
        String? hospitalId;
        String? doctorId;

        //------------Scan each hospital's doctors-----------------\\
        for (final hospital in hospitalsSnap.children) {
          final doctorsSnap = await dbRef
              .child("hospitals/${hospital.key}/doctors")
              .get();

          if (!doctorsSnap.exists) continue;

          for (final doc in doctorsSnap.children) {
            final docMap = Map<String, dynamic>.from(doc.value as Map);

            //------- check Match email-------------------\\
            if (docMap["email"].toString().toLowerCase() == email) {
              //------------------Validate password----------------------\\
              if (docMap["password"] != password) {
                emit(AuthFailure("Invalid password."));
                return;
              }

              doctorData = docMap;
              doctorId = doc.key;
              hospitalId = hospital.key;
              break;
            }
          }

          if (doctorData != null)
            break; //<<<<<<<-----stop scanning once found--\\
        }

        //---------If not found-----------\\
        if (doctorData == null) {
          emit(AuthFailure("Doctor not found."));
          return;
        }

        //--------- emit UserModel--------------\\
        emit(
          AuthSuccess(
            UserModel.fromMap({
              ...doctorData,
              "hospitalId": hospitalId,
              "doctorId": doctorId,
              "role": "Doctor",
            }),
          ),
        );

        print("Doctor Login Success: $doctorId under Hospital $hospitalId");
        return;
      }
      //--------------------------hospital login ----------------------------\\
      if (roleFixed == "Hospital") {
        final snapshot = await dbRef.child("hospitals").get();

        for (final child in snapshot.children) {
          final data = Map<String, dynamic>.from(child.value as Map);

          final codeMatch =
              data["code"]?.toString().trim() == event.emailOrCode.trim();
          final passMatch = data["password"] == event.password;

          if (codeMatch && passMatch) {
            emit(AuthSuccess(UserModel.fromMap({...data, "role": "Hospital"})));
            print(" Hospital Login Success");
            return;
          }
        }

        emit(AuthFailure("Invalid hospital code or password."));
        return;
      }

      //---------------------------admin login --------------------------\\
      if (roleFixed == "Admin") {
        final snapshot = await dbRef.child("admins").get();

        for (final child in snapshot.children) {
          final data = Map<String, dynamic>.from(child.value as Map);

          final emailMatch =
              data["email"]?.toString().trim().toLowerCase() ==
              event.emailOrCode.trim().toLowerCase();

          final passMatch = data["password"] == event.password;

          if (emailMatch && passMatch) {
            emit(AuthSuccess(UserModel.fromMap({...data, "role": "Admin"})));
            print(" Admin Login Success");
            return;
          }
        }

        emit(AuthFailure("Invalid admin credentials."));
        return;
      }

      //------------------------uer login ---------------------------\\
      if (roleFixed == "User") {
        final snapshot = await dbRef.child("users").get();

        for (final child in snapshot.children) {
          final data = Map<String, dynamic>.from(child.value as Map);

          final emailMatch =
              data["email"]?.toString().trim().toLowerCase() ==
              event.emailOrCode.trim().toLowerCase();

          final passMatch = data["password"] == event.password;

          if (emailMatch && passMatch) {
            emit(AuthSuccess(UserModel.fromMap({...data, "role": "User"})));
            print(" User Login Success");
            return;
          }
        }

        emit(AuthFailure("Invalid user credentials."));
        return;
      }

      //-----------should never reach here---------------\\
      emit(AuthFailure("Unknown role selected."));
    } catch (e, st) {
      print("❌ LOGIN ERROR: $e\n$st");
      emit(AuthFailure("Login failed: $e"));
    }
  }
}
