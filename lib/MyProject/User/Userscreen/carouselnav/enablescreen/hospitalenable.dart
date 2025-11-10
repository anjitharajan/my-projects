import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/hospitalscreen/hospitalsmainscreen.dart';

class EnableScreen extends StatefulWidget {
  final String hospitalId;
  final String hospitalName;
  final String hospitalImage;
  final String aboutText;
  final String userId;
  const EnableScreen({
    super.key,
    required this.hospitalId,
    required this.hospitalName,
    required this.hospitalImage,
    required this.aboutText,
    required this.userId,
  });

  @override
  State<EnableScreen> createState() => _EnableScreenState();
}

class _EnableScreenState extends State<EnableScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
    "hospitals",
  );
  bool isLoading = true;
  bool isEnabled = false;

  @override
  void initState() {
    super.initState();
    fetchHospitalStatus();
  }

  Future<void> fetchHospitalStatus() async {
    final snapshot = await _dbRef.child(widget.hospitalId).get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        isEnabled = data["linked"] ?? false;
        isLoading = false;
      });
    } else {
      setState(() {
        isEnabled = false;
        isLoading = false;
      });
    }
  }

  Future<void> enableHospital() async {
    final userRef = FirebaseDatabase.instance.ref().child(
      "users/${widget.userId}/enabledHospital",
    );
    final prevSnapshot = await userRef.get();
    if (prevSnapshot.exists) {
      final prevHospitalId = prevSnapshot.value.toString();
      await _dbRef.child(prevHospitalId).update({"linked": false});
    }

    await _dbRef.child(widget.hospitalId).update({"linked": true});
    await userRef.set(widget.hospitalId);

    setState(() {
      isEnabled = true;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HospitalPage(
          hospitalName: widget.hospitalName,
          hospitalImage: widget.hospitalImage,
          aboutText: widget.aboutText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.hospitalName),
        backgroundColor: const Color.fromARGB(255, 4, 46, 81),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Image.network(
                  widget.hospitalImage,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),
                Text(
                  widget.hospitalName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 4, 46, 81),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    widget.aboutText,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    onPressed: isEnabled ? null : enableHospital,
                    child: Text(
                      isEnabled ? "Already Enabled" : "Enable Hospital",
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
