import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class page1 extends StatefulWidget {
  page1({super.key});

  @override
  State<page1> createState() => _Page1State();
}

class _Page1State extends State<page1> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController hospitalName = TextEditingController();
  final TextEditingController hospitalAddress = TextEditingController();
  final TextEditingController hospitalCode = TextEditingController();
  final TextEditingController hospitalContact = TextEditingController();

  final dbRef = FirebaseDatabase.instance.ref().child("hospitals");

  Future<void> addHospital() async {
    if (_formKey.currentState!.validate()) {
      final newHospital = dbRef.push();

      // 🔹 Auto-generated hospital code
      final autoCode =
          "HOSP${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";

      await newHospital.set({
        "id": newHospital.key,
        "name": hospitalName.text.trim(),
        "address": hospitalAddress.text.trim(),
        "contact": hospitalContact.text.trim(),
        "code": autoCode, // auto-generated code
        "email": "", // will be filled during hospital signup
        "password": "",
        "linked": false, // will be true when hospital signs up
        "createdAt": DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(" Hospital added successfully!\nCode: $autoCode"),
        ),
      );

      // Clear form fields
      hospitalName.clear();
      hospitalAddress.clear();
      hospitalContact.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add New Hospital",
                style:  GoogleFonts.merriweather(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 6, 33, 55)
                ),
              ),
              SizedBox(height: 24),

              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: buildTextFormField(
                            "Hospital Name",
                            hospitalName,
                            "Enter hospital name",
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: buildTextFormField(
                            "Hospital Address",
                            hospitalAddress,
                            "Enter hospital address",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Row 2
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 100, right: 100),
                        child: buildTextFormField(
                          "Hospital Contact",
                          hospitalContact,
                          "Enter hospital contact",
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: addHospital,
                        icon: Icon(Icons.save, size: 24),
                        label: Text("Save", style: GoogleFonts.germaniaOne(
                          fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color.fromARGB(255, 4, 46, 81),
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextFormField(
    String label,
    TextEditingController controller,
    String? validationText,
  ) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        validator: (val) => val == null || val.isEmpty ? validationText : null,
        style:  GoogleFonts.germaniaOne(
          color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.ibarraRealNova(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white38),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
