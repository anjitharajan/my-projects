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
      // ------------------------------
      // 🔹 Step 1: Validate fields
      // ------------------------------
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

      // ------------------------------
      // 🔹 Step 2: Admin Signup
      // ------------------------------
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

      // ------------------------------
      // 🔹 Step 3: Hospital Signup
      // ------------------------------
      if (user.role == "Hospital") {
        final hospitalSnapshot = await dbRef
            .child('hospitals')
            .orderByChild('code')
            .equalTo(user.adminCode)
            .get();

        if (hospitalSnapshot.exists) {
          final hospitalKey = hospitalSnapshot.children.first.key!;
          await dbRef.child('hospitals/$hospitalKey').update({
            "name": user.name ?? "No Name",
            "email": email,
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
                email: email,
                password: user.password,
                role: "Hospital",
              ),
            ),
          );
        } else {
          emit(AuthFailure("Invalid Hospital Code. Please contact admin."));
        }
        return;
      }

      // ------------------------------
      // 🔹 Step 4: Doctor Signup (Updated to prevent duplication)
      // ------------------------------
      // if (user.role == "Doctor") {
      //   try {
      //     final email = user.email!.trim().toLowerCase();

      //     // ✅ 1️⃣ Check if this doctor already exists (by email)
      //     final existingDoctorSnap = await dbRef
      //         .child('doctors')
      //         .orderByChild('email')
      //         .equalTo(email)
      //         .get();

      //     if (existingDoctorSnap.exists) {
      //       // Existing doctor found — prevent duplicate
      //       final existingKey = existingDoctorSnap.children.first.key!;
      //       final existingData = Map<String, dynamic>.from(
      //         existingDoctorSnap.children.first.value as Map,
      //       );

      //       emit(AuthSuccess(UserModel.fromMap(existingData)));
      //       return;
      //     }

      //     // ✅ 2️⃣ Verify hospital code before creating
      //     if (user.adminCode == null || user.adminCode!.isEmpty) {
      //       emit(AuthFailure("Hospital Code is required for Doctor Signup"));
      //       return;
      //     }

      //     final hospitalSnap = await dbRef
      //         .child('hospitals')
      //         .orderByChild('code')
      //         .equalTo(user.adminCode)
      //         .get();

      //     if (!hospitalSnap.exists) {
      //       emit(AuthFailure("Invalid Hospital Code."));
      //       return;
      //     }

      //     final hospitalKey = hospitalSnap.children.first.key!;
      //     final hospitalData = Map<String, dynamic>.from(
      //       hospitalSnap.children.first.value as Map,
      //     );
      //     final hospitalName = hospitalData["name"] ?? "Unknown Hospital";

      //     // ✅ 3️⃣ Check if doctor was already added by hospital
      //     final hospitalDoctorSnap = await dbRef
      //         .child('hospitals/$hospitalKey/doctors')
      //         .get();

      //     if (hospitalDoctorSnap.exists) {
      //       for (final doc in hospitalDoctorSnap.children) {
      //         final d = Map<String, dynamic>.from(doc.value as Map);
      //         if (d['email']?.toString().toLowerCase() == email) {
      //           // Doctor already added by hospital
      //           await dbRef.child('doctors/${doc.key}').update({
      //             "password": user.password,
      //             "updatedAt": DateTime.now().toIso8601String(),
      //           });

      //           emit(
      //             AuthSuccess(
      //               UserModel.fromMap({...d, "password": user.password}),
      //             ),
      //           );
      //           return;
      //         }
      //       }
      //     }

      //     // ✅ 4️⃣ If no existing doctor, create new one
      //     final uid = _uuid.v4();
      //     final doctorData = {
      //       "id": uid,
      //       "name": user.name ?? "No Name",
      //       "email": email,
      //       "password": user.password,
      //       "role": "Doctor",
      //       "hospitalName": hospitalName,
      //       "hospitalId": hospitalKey,
      //       "hospitalCode": user.adminCode,
      //       "specialization": user.specialization ?? "General",
      //       "createdAt": DateTime.now().toIso8601String(),
      //       "image": user.image ?? "https://via.placeholder.com/400",
      //     };

      //     await dbRef.child("doctors/$uid").set(doctorData);
      //     await dbRef
      //         .child("hospitals/$hospitalKey/doctors/$uid")
      //         .set(doctorData);

      //     emit(AuthSuccess(UserModel.fromMap(doctorData)));
      //     return;
      //   } catch (e) {
      //     emit(AuthFailure("Doctor Signup Error: $e"));
      //     return;
      //   }
      // }

      //added new part under

      // ------------------------------
      // 🔹 Step 4: Doctor Signup (Final Version)
      // ------------------------------
      // if (user.role == "Doctor") {
      //   try {
      //     final email = user.email!.trim().toLowerCase();

      //     // 1️⃣ Check doctor lookup table (email → doctorId)
      //     final lookup = await dbRef.child("doctor_lookup/$email").get();

      //     if (lookup.exists) {
      //       final doctorId = lookup.value.toString();

      //       // Doctor was already added by hospital → update password only
      //       final doctorSnap = await dbRef.child("doctors/$doctorId").get();

      //       if (doctorSnap.exists) {
      //         await dbRef.child("doctors/$doctorId").update({
      //           "password": user.password,
      //           "updatedAt": DateTime.now().toIso8601String(),
      //         });

      //         emit(AuthSuccess(UserModel.fromMap(
      //             Map<String, dynamic>.from(doctorSnap.value as Map)
      //               ..["password"] = user.password
      //         )));
      //         return;
      //       }
      //     }

      //     // 2️⃣ Hospital Code validation
      //     if (user.adminCode == null || user.adminCode!.isEmpty) {
      //       emit(AuthFailure("Hospital Code is required"));
      //       return;
      //     }

      //     final hospitalSnap = await dbRef
      //         .child('hospitals')
      //         .orderByChild('code')
      //         .equalTo(user.adminCode)
      //         .get();

      //     if (!hospitalSnap.exists) {
      //       emit(AuthFailure("Invalid Hospital Code"));
      //       return;
      //     }

      //     final hospitalId = hospitalSnap.children.first.key!;
      //     final hospitalName =
      //         (hospitalSnap.children.first.value as Map)["name"] ?? "Unknown";

      //     // 3️⃣ Create doctor ONLY under hospital
      //     final doctorId = _uuid.v4();

      //     final doctorData = {
      //       "id": doctorId,
      //       "name": user.name,
      //       "email": email,
      //       "password": user.password,
      //       "role": "Doctor",
      //       "hospitalId": hospitalId,
      //       "hospitalName": hospitalName,
      //       "hospitalCode": user.adminCode,
      //       "specialization": user.specialization ?? "General",
      //       "createdAt": DateTime.now().toIso8601String(),
      //       "image": user.image ?? "https://via.placeholder.com/400",
      //     };

      //     // Save inside hospital → correct location
      //     await dbRef.child("hospitals/$hospitalId/doctors/$doctorId").set(doctorData);

      //     // Add lookup entry for login
      //     await dbRef.child("doctor_lookup/$email").set(doctorId);

      //     emit(AuthSuccess(UserModel.fromMap(doctorData)));
      //     return;

      //   } catch (e) {
      //     emit(AuthFailure("Doctor Signup Error: $e"));
      //     return;
      //   }
      // }

      // ------------------------------
      // 🔹 Step 5: Patient / Default Signup
      // ------------------------------
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

  //--------------------------onlogin--the original part----------------------------------//

  //   Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
  //     emit(AuthLoading());

  //     try {
  //       // Normalize role text (handles lowercase or mixed case)
  //       final normalizedRole = event.role.trim();
  //       final roleFixed =
  //           normalizedRole[0].toUpperCase() +
  //           normalizedRole.substring(1).toLowerCase();

  //       // Map role to correct database node
  //       final node = roleFixed == "Admin"
  //           ? "admins"
  //           : (roleFixed == "Hospital"
  //                 ? "hospitals"
  //                 : (roleFixed == "Doctor" ? "doctors" : "users"));

  //       print("🔍 Trying to log in as $roleFixed from node: $node");

  //       // Get all users under the node
  //       final snapshot = await dbRef.child(node).get();

  //       if (!snapshot.exists) {
  //         emit(AuthFailure("No $roleFixed data found."));
  //         return;
  //       }

  //       UserModel? loggedInUser;
  //       bool found = false;

  //       // Loop through each record and match credentials
  //       for (final child in snapshot.children) {
  //         final userData = Map<String, dynamic>.from(child.value as Map);

  //         // Match by email for everyone except Hospital (uses hospital code)
  //         final match = roleFixed == "Hospital"
  //             ? (userData["code"]?.toString().trim() == event.emailOrCode.trim())
  //             : (userData["email"]?.toString().toLowerCase() ==
  //                   event.emailOrCode.toLowerCase());

  //         if (match && userData["password"] == event.password) {
  //           found = true;
  //           final roleFromDb = (userData["role"] ?? roleFixed).toString();
  //           final roleNormalized =
  //               roleFromDb[0].toUpperCase() +
  //               roleFromDb.substring(1).toLowerCase();

  //           loggedInUser = UserModel.fromMap({
  //             ...userData,
  //             "role": roleNormalized,
  //           });

  //           print("✅ Login successful for role: $roleNormalized");
  //           break;
  //         }
  //       }

  //       // Emit result
  //       if (found && loggedInUser != null) {
  //         emit(AuthSuccess(loggedInUser));
  //       } else {
  //         emit(AuthFailure("Invalid $roleFixed credentials."));
  //       }
  //     } catch (e, st) {
  //       print("❌ LOGIN ERROR: $e\n$st");
  //       emit(AuthFailure("Login failed: $e"));
  //     }
  //   }
  // }

  //-------------------added part---//
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Normalize role text
      final normalizedRole = event.role.trim();
      final roleFixed =
          normalizedRole[0].toUpperCase() +
          normalizedRole.substring(1).toLowerCase();

      print(" Login Attempt → Role: $roleFixed");

      // -------------------------------
      // 1️⃣ DOCTOR LOGIN (special logic)
      // -------------------------------
      if (roleFixed == "Doctor") {
         final email = event.emailOrCode.trim().toLowerCase();
  final password = event.password;
        // String encodeEmail(String email) {
        //   return email.trim().toLowerCase().replaceAll('.', ',');
        // }

        // final emailKey = encodeEmail(event.emailOrCode);
        // final lookupSnap = await dbRef.child("doctor_lookup/$emailKey").get();

        // if (!lookupSnap.exists) {
        //   emit(AuthFailure("Doctor not found."));
        //   return;
        // }

        // final doctorId = lookupSnap.value.toString();
        // print(" Found doctorId = $doctorId");

        // Search doctor inside all hospitals
        final hospitalsSnap = await dbRef.child("hospitals").get();

        Map<String, dynamic>? doctorData;
        String? hospitalId;
          String? doctorId;

       // 2️⃣ Scan each hospital's doctors
  for (final hospital in hospitalsSnap.children) {
    final doctorsSnap = await dbRef
        .child("hospitals/${hospital.key}/doctors")
        .get();

             if (!doctorsSnap.exists) continue;

    for (final doc in doctorsSnap.children) {
      final docMap = Map<String, dynamic>.from(doc.value as Map);

      // 3️⃣ Match email
      if (docMap["email"].toString().toLowerCase() == email) {
        // 4️⃣ Validate password
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

    if (doctorData != null) break; // stop scanning once found
  }

  // 5️⃣ If not found
  if (doctorData == null) {
    emit(AuthFailure("Doctor not found."));
    return;
  }

  // 6️⃣ Success → emit UserModel
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
      // --------------------------------
      // 2️⃣ HOSPITAL LOGIN
      // --------------------------------
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

      // --------------------------------
      // 3️⃣ ADMIN LOGIN
      // --------------------------------
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

      // --------------------------------
      // 4️⃣ USER LOGIN
      // --------------------------------
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

      // Should never reach here
      emit(AuthFailure("Unknown role selected."));
    } catch (e, st) {
      print("❌ LOGIN ERROR: $e\n$st");
      emit(AuthFailure("Login failed: $e"));
    }
  }
}
