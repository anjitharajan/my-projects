import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:virmedo/MyProject/Hospital/Hospitalhome/hospitalhome.dart';

class Enablescreen extends StatefulWidget {
  final String hospitalId;
  final String hospitalName;
  final String hospitalImage;
  final String aboutText;

  Enablescreen({
    super.key,
    required this.hospitalId,
    required this.hospitalName,
    required this.hospitalImage,
    required this.aboutText,
  });

  @override
  State<Enablescreen> createState() => _EnablescreenState();
}

class _EnablescreenState extends State<Enablescreen> {
  bool isEnabled = false;

  Future<void> connectUserToHospital(String hospitalId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User not logged in.")));
      return;
    }

    final dbRef = FirebaseDatabase.instance.ref();

    await dbRef.child("users/$userId/connectedHospital").set(hospitalId);
    await dbRef.child("hospitals/$hospitalId/connectedUsers/$userId").set(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 4, 46, 81),
          ),
          onPressed: () {
            Navigator.pop(context, isEnabled ? widget.hospitalName : null);
          },
        ),
        title: Text(
          widget.hospitalName,
          style: TextStyle(color: Color.fromARGB(255, 4, 46, 81)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              widget.hospitalImage,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Text(
              widget.hospitalName,
              style: TextStyle(
                color: Color.fromARGB(255, 4, 46, 81),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                " enable this hospital to link it with user account for live updates.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isEnabled
                    ? Colors.grey
                    : Color.fromARGB(255, 4, 46, 81),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              onPressed: isEnabled
                  ? null
                  : () async {
                      await connectUserToHospital(widget.hospitalId);
                      setState(() => isEnabled = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "${widget.hospitalName} enabled successfully",
                          ),
                        ),
                      );

                      String about;
                      switch (widget.hospitalName) {
                        case "Aster Medicity Hospital":
                          about =
                              "Aster Medicity is one of the most advanced healthcare destinations in South Asia.";
                          break;
                        case "Medical Trust Hospital":
                          about =
                              "Medical Trust Hospital provides world-class facilities with compassionate care.";
                          break;
                        case "Welcare Hospital":
                          about =
                              "Welcare Hospital focuses on modern technology and patient-first healthcare.";
                          break;
                        case "Renai Medicity Hospital":
                          about =
                              "Renai Medicity combines expert doctors and innovation for holistic health services.";
                          break;
                        case "Lakeshore Hospital":
                          about =
                              "Lakeshore Hospital offers advanced multispecialty healthcare with a focus on quality.";
                          break;
                        default:
                          about =
                              "Trusted healthcare partner for your wellness journey.";
                      }

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HospitalMainPage(
                            hospitalId: widget.hospitalId,
                            hospitalName: widget.hospitalName,
                            hospitalImage: widget.hospitalImage,
                            aboutText: about,
                          ),
                        ),
                      );

                      Navigator.pop(context, widget.hospitalName);
                    },
              child: Text(
                isEnabled ? "Enabled" : "Enable Hospital",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
