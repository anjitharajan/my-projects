import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientPage extends StatefulWidget {
  final String hospitalId;

  const PatientPage({super.key, required this.hospitalId});

  @override
  State<PatientPage> createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  bool isLoading = true;

  //------------ user details maping------------------\\
  List<Map<String, dynamic>> userDetails = [];

  @override
  void initState() {
    super.initState();
    fetchConnectedUsers();
  }

    //------------ connected users fetching ------------------\\
  Future<void> fetchConnectedUsers() async {
    final snapshot = await _dbRef
        .child("hospitals/${widget.hospitalId}/connectedUsers")
        .get();

    if (!snapshot.exists || snapshot.value == null) {
      setState(() {
        userDetails = [];
        isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> connected = Map<String, dynamic>.from(
      snapshot.value as Map,
    );

    await fetchUserDetails(connected.keys.toList());
  }

   //------------ fetching connected  user information------------------\\
  Future<void> fetchUserDetails(List<String> userIds) async {
    List<Map<String, dynamic>> tempList = [];

    for (String userId in userIds) {
      final snap = await _dbRef.child("users/$userId").get();

      if (snap.exists && snap.value != null) {
        final data = Map<String, dynamic>.from(snap.value as Map);

        tempList.add({
          "userId": userId,
          "name": data["name"] ?? "Unknown",
          "email": data["email"] ?? "No email",
        
        });
      }
    }

    setState(() {
      userDetails = tempList;
      isLoading = false;
    });
  }

    //------------ connected user  removing ------------------\\
  Future<void> removeUser(String userId) async {
    await _dbRef
        .child("hospitals/${widget.hospitalId}/connectedUsers/$userId")
        .remove();

    setState(() {
      userDetails.removeWhere((user) => user["userId"] == userId);
    });
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
          "Patients",
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userDetails.isEmpty
          ? const Center(
              child: Text(
                "No patients enabled yet.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userDetails.length,
              itemBuilder: (context, index) {
                final user = userDetails[index];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Color.fromARGB(255, 6, 33, 55)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                       contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.person,
                          color: Color.fromARGB(255, 4, 46, 81),
                          size: 28,
                        ),
                      ),
                      title: Text(
                        user["name"],
                        style: GoogleFonts.neuton(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Email: ${user["email"]}",  style: GoogleFonts.germaniaOne(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),),
                          
                        ],
                      ),

                      //------------- detete connected user----------------\\
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Remove User"),
                              content: Text(
                                "Are you sure you want to remove ${user["name"]}?",
                              ),
                              actions: [
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                  child: const Text(
                                    "Remove",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    removeUser(user["userId"]);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
