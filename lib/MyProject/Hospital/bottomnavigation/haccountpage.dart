import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virmedo/MyProject/signup/login/loginpage.dart';


class AccountPage extends StatefulWidget {
  final String hospitalId;
  AccountPage({super.key, required this.hospitalId});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final dbRef = FirebaseDatabase.instance.ref();
  String hospitalName = "";
  String hospitalEmail = "";
  String hospitalAddress = "";

  @override
  void initState() {
    super.initState();
    fetchHospitalDetails();
  }

  Future<void> fetchHospitalDetails() async {
    final ref = FirebaseDatabase.instance.ref("hospitals/${widget.hospitalId}");

    final snapshot = await ref.get();

    if (snapshot.exists) {
      setState(() {
        hospitalName = snapshot.child("name").value.toString();
        hospitalEmail = snapshot.child("email").value.toString();
        hospitalAddress = snapshot.child("address").value.toString().isEmpty
            ? "No address provided"
            : snapshot.child("address").value.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Account",
          style: GoogleFonts.merriweather(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 4, 46, 81), Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          height: 350,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 10,
                spreadRadius: 3,
                offset: Offset(0, 6), // shadow direction
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hospital Name:",
                style: GoogleFonts.dmSerifDisplay(
                  color: Colors.white70, fontSize: 16,fontWeight: FontWeight.bold),
              ),
              Text(
                hospitalName,
                style:GoogleFonts.merriweather(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Email:",
                     style: GoogleFonts.dmSerifDisplay(
                  color: Colors.white70, fontSize: 14,fontWeight: FontWeight.bold),
              ),
              Text(
                hospitalEmail,
                style:GoogleFonts.merriweather(
                  color: Colors.white, fontSize: 16),
              ),

              const SizedBox(height: 20),

              Text(
                "Address:",
                      style: GoogleFonts.dmSerifDisplay(
                  color: Colors.white70, fontSize: 14,fontWeight: FontWeight.bold),
              ),
              Text(
                hospitalAddress,
                style:GoogleFonts.merriweather(
                  color: Colors.white, fontSize: 16),
              ),

              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.white,size: 22,),
                    label: Text(
                      "Logout",
                      style:  GoogleFonts.germaniaOne(
                        color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
