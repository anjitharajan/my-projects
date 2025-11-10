import 'package:flutter/material.dart';
import 'package:virmedo/MyProject/signup/signupscreen/signupscreen.dart';

class AccountPage extends StatelessWidget {
   AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:  Color.fromARGB(255, 4, 46, 81),
        title:  Text("Account", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding:  EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                "https://cdn-icons-png.flaticon.com/512/1047/1047711.png",
              ),
            ),
             SizedBox(height: 20),
             Text(
              "Hospital Name: City Health Center",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
             SizedBox(height: 8),
             Text("Email: cityhealth@hospital.com"),
             SizedBox(height: 8),
             Text("Address: 123 Medical Street, Kochi, India"),
             SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:  EdgeInsets.symmetric(
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
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                icon:  Icon(Icons.logout, color: Colors.white),
                label:  Text(
                  "Logout",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
