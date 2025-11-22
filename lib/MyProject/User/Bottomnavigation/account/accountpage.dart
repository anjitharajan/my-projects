import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virmedo/MyProject/User/Bottomnavigation/account/editpage.dart';
import 'package:virmedo/MyProject/signup/login/loginpage.dart';
import 'package:virmedo/MyProject/signup/signupscreen/signupscreen.dart';

class Accountpage extends StatefulWidget {
  Accountpage({super.key});

  @override
  State<Accountpage> createState() => _AccountpageState();
}

class _AccountpageState extends State<Accountpage> {
  String name = "";
  String email = "";
  String username = "";
  String phone = "";
  String? _imagePath;
  bool showProfileDetails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,



      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            CircleAvatar(
              radius: 45,
              backgroundImage: _imagePath != null
                  ? FileImage(File(_imagePath!))
                  : AssetImage('assets/profile.jpg'),
            ),

            SizedBox(height: 10),
            Text(
              name.isEmpty ? "Your Name" : name,
              style:  GoogleFonts.germaniaOne(
                fontSize: 18, ),
            ),
            Text(
              email.isEmpty ? "@email.com" : email,
              style:  GoogleFonts.germaniaOne(
                color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final updatedData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      name: name,
                      email: email,
                      username: username,
                      phone: phone,
                    ),
                  ),
                );

                if (updatedData != null && mounted) {
                  setState(() {
                    name = updatedData['name'] ?? name;
                    email = updatedData['email'] ?? email;
                    username = updatedData['username'] ?? username;
                    phone = updatedData['phone'] ?? phone;
                    _imagePath = updatedData['imagePath'];
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 4, 46, 81),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              ),
              child: Text(
                "Edit Profile",
                style:GoogleFonts.neuton(
                  color: Colors.white, fontSize: 18),
              ),
            ),

            SizedBox(height: 25),

            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Color.fromARGB(255, 4, 46, 81),
                    ),
                    title: Text(
                      "My Profile",
                      style: GoogleFonts.germaniaOne(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 4, 46, 81),
                      ),
                    ),
                    trailing: Icon(
                      showProfileDetails
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Color.fromARGB(255, 4, 46, 81),
                    ),
                    onTap: () {
                      setState(() {
                        showProfileDetails = !showProfileDetails;
                      });
                    },
                  ),

                  if (showProfileDetails)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      padding: EdgeInsets.all(12),
                      
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow("Name", name),
                          _infoRow("Email", email),
                          _infoRow("Username", username),
                          _infoRow("Phone", phone),
                        ],
                      ),
                    ),

                  Divider(color: Color.fromARGB(255, 4, 46, 81)),

                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.redAccent),
                    title: Text(
                      "Log out",
                      style: GoogleFonts.germaniaOne(
                        color: Colors.redAccent),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.red,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Logged out successfully")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label : ",
            style:  GoogleFonts.merriweather(
              fontWeight: FontWeight.w100,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Expanded(child: Text(value, style:  GoogleFonts.merriweather(
            fontSize: 14))),
        ],
      ),
    );
  }
}
