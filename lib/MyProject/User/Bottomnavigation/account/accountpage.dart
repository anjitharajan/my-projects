import 'dart:io';
import 'package:flutter/material.dart';
import 'package:virmedo/MyProject/User/Bottomnavigation/account/editpage.dart';
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

      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   centerTitle: true,
      //   title:  Text(
      //     "My Profile",
      //     style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      //   ),
      //   leading: IconButton(
      //     icon:  Icon(Icons.arrow_back_ios, color: Colors.black),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   actions:  [
      //     Padding(
      //       padding: EdgeInsets.only(right: 16),
      //       child: Icon(Icons.settings_outlined, color: Colors.black),
      //     ),
      //   ],
      // ),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              email.isEmpty ? "@email.com" : email,
              style: TextStyle(color: Colors.grey, fontSize: 14),
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
                style: TextStyle(color: Colors.white, fontSize: 16),
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
                      style: TextStyle(
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
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.red,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
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
            style: TextStyle(
              fontWeight: FontWeight.w100,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
