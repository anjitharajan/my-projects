import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  bool isLoading = true;
  bool isEnabled = false;

  @override
  void initState() {
    super.initState();
    fetchHospitalStatus();
  }

  ///  Check if hospital is already enabled by this user
  Future<void> fetchHospitalStatus() async {
    final snapshot = await _dbRef
        .child("users/${widget.userId}/enabledHospitals/${widget.hospitalId}")
        .get();

    setState(() {
      isEnabled = snapshot.exists;
      isLoading = false;
    });
  }

  /// Enable connection between user and hospital (two-way link)
  Future<void> enableHospital() async {
    try {
      // Store hospital under user's enabled hospitals
      await _dbRef
          .child("users/${widget.userId}/enabledHospitals/${widget.hospitalId}")
          .set({
        "hospitalName": widget.hospitalName,
        "enabledAt": DateTime.now().toIso8601String(),
      });

      // Store user under hospital’s connected users
   await _dbRef
  .child("hospitals/${widget.hospitalId}/connectedUsers/${widget.userId}")
  .set({
    //-------- original--------//
    // "name": (await _dbRef.child("users/${widget.userId}/name").get()).value,
    //--------//
    "name": (await _dbRef.child("users/${widget.userId}/userDetails/name").get()).value,
 //-------------//
    "connectedAt": DateTime.now().toIso8601String(),
  });

      setState(() {
        isEnabled = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hospital successfully enabled!")),
      );

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => HospitalPage(
      hospitalId: widget.hospitalId,   
      hospitalName: widget.hospitalName,
      hospitalImage: widget.hospitalImage,
      aboutText: widget.aboutText,
      userId: widget.userId,
    
          
    ),
  ),
);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error enabling hospital: $e")),
      );
    }
  }

  ///  Cancel hospital link (remove both sides)
  Future<void> cancelHospitalLink() async {
    try {
      await _dbRef
          .child("users/${widget.userId}/enabledHospitals/${widget.hospitalId}")
          .remove();
      await _dbRef
          .child("hospitals/${widget.hospitalId}/connectedUsers/${widget.userId}")
          .remove();

      setState(() {
        isEnabled = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hospital link cancelled successfully!")),
      );
         Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cancelling link: $e")),
      );
    }
 

  }

  ///  Show confirmation dialog before unlinking
  Future<void> _showCancelDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Connection"),
        content: const Text(
            "Are you sure you want to cancel the link with this hospital?"),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Yes, Cancel"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      cancelHospitalLink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          centerTitle: true,
        elevation: 0,
        title: Text(
          widget.hospitalName,
         style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),),
        iconTheme: IconThemeData(color: Colors.white), // white icons
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 4, 46, 81), Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Image.network(
                  widget.hospitalImage,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Text(
                  widget.hospitalName,
                  style: const TextStyle(
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
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                //const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: isEnabled ? null : enableHospital,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEnabled
                              ? Colors.grey
                              : const Color.fromARGB(255, 4, 46, 81),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        child: Text(
                          // isEnabled ? "Already Enabled" : "Enable Hospital",
                          isEnabled ? "Enabled ✔" : "Enable Hospital",

                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isEnabled)
                        OutlinedButton(
                          onPressed: _showCancelDialog,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red, width: 2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35, vertical: 12),
                          ),
                          child: const Text(
                            "Cancel Link",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
