// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:virmedo/MyProject/Hospital/Hospitalhome/hospitalhome.dart';

// class HospitalLoginPage extends StatefulWidget {
//   const HospitalLoginPage({super.key});

//   @override
//   State<HospitalLoginPage> createState() => _HospitalLoginPageState();
// }

// class _HospitalLoginPageState extends State<HospitalLoginPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;

//   final _auth = FirebaseAuth.instance;
//   final _dbRef = FirebaseDatabase.instance.ref().child('hospitals');

//   Future<void> _loginHospital() async {
//     setState(() => _loading = true);
//     try {
//       final cred = await _auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );

//       final snapshot = await _dbRef
//           .orderByChild('authUid')
//           .equalTo(cred.user!.uid)
//           .get();

//       if (!snapshot.exists) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('No hospital linked to this account')),
//         );
//         setState(() => _loading = false);
//         return;
//       }

//       final hospital = snapshot.children.first;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => HospitalMainPage(
//             hospitalId: hospital.key!,
//             hospitalName: hospital.child('name').value.toString(),
//             hospitalImage: hospital.child('image').value?.toString() ?? '',
//             aboutText: hospital.child('address').value.toString(),
//               userId: hospital.key!,
//           ),
//         ),
//       );
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Hospital Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _loading ? null : _loginHospital,
//               child: _loading ? CircularProgressIndicator() : Text('Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
