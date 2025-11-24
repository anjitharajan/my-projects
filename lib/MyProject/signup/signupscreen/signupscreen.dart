import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virmedo/MyProject/Admin/Homepage/adminhome.dart';
import 'package:virmedo/MyProject/Hospital/Hospitalhome/hospitalhome.dart';
import 'package:virmedo/MyProject/User/Userscreen/home/userdashb.dart';
import 'package:virmedo/MyProject/signup/bloc/loginbloc_bloc.dart';
import 'package:virmedo/MyProject/signup/bloc/loginbloc_event.dart';
import 'package:virmedo/MyProject/signup/bloc/loginbloc_state.dart';
import 'package:virmedo/MyProject/signup/login/loginpage.dart';
import 'package:virmedo/MyProject/signup/modelclass/signupmodelclass.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _adminCode = TextEditingController();

  String _role = 'User';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _address.dispose();
    _adminCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 246, 248),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(
          child: Text(
            "Sign Up",
            style: GoogleFonts.dmSerifText(
              fontSize: 29,
              color: Color.fromARGB(255, 4, 46, 81),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            final user = state.user;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Sign Up Successful as ${user.role}")),
            );

            if (user.role == "Admin") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AdminDashboard()),
              );
            } else if (user.role == "Hospital") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HospitalMainPage(
                    hospitalId: user.id ?? '',
                    hospitalName: user.name ?? 'Hospital',
                    hospitalImage:
                        user.image ?? 'https://via.placeholder.com/400',
                    aboutText: user.address ?? 'No details available',
                    contact: user.contact ?? 'N/A', // now valid
                    hospitalCode: user.adminCode ?? '', // optional
                    userId: user.id ?? '',
                  ),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => Userdashboard(
                    userId: user.id ?? '',
                    userName: user.name ?? 'User',
                  ),
                ),
              );
            }
          } else if (state is AuthFailure) {
            print("SIGNUP ERROR: ${state.error}");
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },

        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: Container(
                width: screenSize.width * 0.9,
                height: screenSize.height * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black, blurRadius: 8)],
                  gradient: LinearGradient(
                    colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _role,
                          dropdownColor: Color(0xFF0D47A1),
                          iconEnabledColor: Colors.white,
                          style: GoogleFonts.almendra(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          items: ['User', 'Hospital', 'Admin']
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _role = val!;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Select Role",
                            labelStyle: GoogleFonts.grenzeGotisch(
                              color: Color.fromARGB(255, 4, 46, 81),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),

                        if (_role != 'Admin') _buildTextField(_name, "Name"),
                        if (_role == 'Hospital')
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFormField(
                              controller: _adminCode,
                              style: GoogleFonts.grenzeGotisch(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 4, 46, 81),
                              ),
                              decoration: InputDecoration(
                                labelText: "Hospital Code",
                                labelStyle: GoogleFonts.grenzeGotisch(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),

                                border: OutlineInputBorder(),
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? "Please enter your hospital code"
                                  : null,
                            ),
                          ),

                        if (_role == 'Admin')
                          _buildTextField(_adminCode, "Admin Code"),
                        _buildTextField(_email, "Email"),
                        _buildTextField(_password, "Password", obscure: true),
                        SizedBox(height: 40),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            elevation: 5,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              BlocProvider.of<AuthBloc>(context).add(
                                SignUpEvent(
                                  UserModel(
                                    name: _name.text,
                                    email: _email.text,
                                    password: _password.text,
                                    role: _role,
                                    address: _address.text,
                                    adminCode: _adminCode.text,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            "Sign up",
                            style: GoogleFonts.limelight(
                              color: Color.fromARGB(255, 4, 46, 81),
                              fontWeight: FontWeight.w500,
                              fontSize: 19,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Please Login !...",
                            style: GoogleFonts.agbalumo(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        style: GoogleFonts.grenzeGotisch(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 4, 46, 81),
        ),
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.grenzeGotisch(color: Colors.white),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        validator: (val) => val!.isEmpty ? "Enter $label" : null,
      ),
    );
  }
}
