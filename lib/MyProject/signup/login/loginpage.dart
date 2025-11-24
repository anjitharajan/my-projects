import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virmedo/MyProject/Admin/Homepage/adminhome.dart';
import 'package:virmedo/MyProject/Doctor/Doctorhome/doctorhome.dart';
import 'package:virmedo/MyProject/Hospital/Hospitalhome/hospitalhome.dart';
import 'package:virmedo/MyProject/User/Userscreen/home/userdashb.dart';
import 'package:virmedo/MyProject/signup/bloc/loginbloc_bloc.dart';
import 'package:virmedo/MyProject/signup/bloc/loginbloc_event.dart';
import 'package:virmedo/MyProject/signup/bloc/loginbloc_state.dart';
import 'package:virmedo/MyProject/signup/signupscreen/signupscreen.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailOrCodeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = "User";

  @override
  Widget build(BuildContext context) {
    final gradientColors = [Colors.blue, Color.fromARGB(255, 4, 46, 81)];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error)));
            }

            if (state is AuthSuccess) {
              final user = state.user;
              final role = user.role;

              if (role == "Admin") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AdminDashboard()),
                );
              } else if (role == "Hospital") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HospitalMainPage(
                      hospitalId: user.id ?? '',
                      hospitalName: user.name ?? 'Hospital',
                      hospitalImage: user.image ?? '',
                      aboutText: user.address ?? 'No details available',
                      userId: user.id ?? '',
                    ),
                  ),
                );
              } else if (role == "Doctor") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorAppointmentsPage(
                      doctorId: user.doctorId ?? '',

                      doctorName: user.name ?? 'Doctor',
                      hospitalId: user.hospitalId ?? '',
                    ),
                  ),
                );
              } else if (role == "User") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Userdashboard(
                      userId: user.id ?? '',
                      userName: user.name ?? 'User',
                    //  userEmail: user.email ?? '',

                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Unknown role: $role")));
              }
            }
          },

          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(28.0),
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          "Login to your account",
                          style: GoogleFonts.dmSerifText(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 4, 46, 81),
                          ),
                        ),
                        SizedBox(height: 30),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 4, 46, 81),
                                Colors.blue,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(color: Colors.grey, blurRadius: 8),
                            ],
                          ),
                          child: DropdownButton<String>(
                            value: selectedRole,
                            isExpanded: true,
                            dropdownColor: Color(0xFF0D47A1),
                            underline: SizedBox(),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                            style: GoogleFonts.almendra(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            onChanged: (val) =>
                                setState(() => selectedRole = val!),
                            items: const [
                              DropdownMenuItem(
                                value: "Admin",
                                child: Text("Admin"),
                              ),
                              DropdownMenuItem(
                                value: "Hospital",
                                child: Text("Hospital"),
                              ),
                              DropdownMenuItem(
                                value: "Doctor",
                                child: Text("Doctor"),
                              ),
                              DropdownMenuItem(
                                value: "User",
                                child: Text("User"),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        TextField(
                          controller: emailOrCodeController,
                          style: GoogleFonts.grenzeGotisch(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 4, 46, 81),
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              selectedRole == "Hospital"
                                  ? Icons.local_hospital
                                  : Icons.email,
                              color: gradientColors[1],
                            ),
                            labelText: selectedRole == "Hospital"
                                ? "Hospital Code"
                                : "Email",
                            labelStyle: GoogleFonts.grenzeGotisch(
                              color: Color.fromARGB(255, 4, 46, 81),
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock,
                              color: gradientColors[1],
                            ),
                            labelText: "Password",
                            labelStyle: GoogleFonts.grenzeGotisch(
                              color: Color.fromARGB(255, 4, 46, 81),
                              fontWeight: FontWeight.w600,
                            ),

                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 35,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 11,
                            shadowColor: Colors.black,
                          ),
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  final emailOrCode = emailOrCodeController.text
                                      .trim();
                                  final password = passwordController.text
                                      .trim();

                                  if (emailOrCode.isEmpty || password.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Please fill all fields"),
                                      ),
                                    );
                                    return;
                                  }

                                  BlocProvider.of<AuthBloc>(context).add(
                                    LoginEvent(
                                      emailOrCode: emailOrCode,
                                      password: password,
                                      role: selectedRole,
                                    ),
                                  );
                                },
                          child: state is AuthLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Login",
                                  style: GoogleFonts.limelight(
                                    color: Color.fromARGB(255, 4, 46, 81),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        SizedBox(height: 16),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Don't have an account? Sign Up !...",
                            style: GoogleFonts.agbalumo(
                              color: gradientColors[1],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
