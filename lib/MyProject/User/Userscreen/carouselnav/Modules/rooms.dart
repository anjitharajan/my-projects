import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RoomScreen extends StatelessWidget {
  final String userId;

  RoomScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Room"),
        backgroundColor: const Color(0xFF043051),
      ),

      body: FutureBuilder(
        future: dbRef.child("users/$userId/allocatedRoom").get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "No room allocated yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          final allocData = Map<String, dynamic>.from(
            snapshot.data!.value as Map,
          );

          final hospitalId = allocData["hospitalId"];
          final roomNumber = allocData["roomNumber"];
          final allocatedAt = allocData["allocatedAt"];

          //---------------- fetching hospital name-----------------\\
          return FutureBuilder(
            future: dbRef.child("hospitals/$hospitalId/name").get(),
            builder: (context, hospSnap) {
              if (!hospSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final hospitalName = hospSnap.data!.value ?? "Unknown Hospital";

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent,
                          Color.fromARGB(255, 4, 46, 81),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Card(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 25,
                          horizontal: 20,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.meeting_room,
                              size: 80,
                              color: Colors.white,
                            ),

                            const SizedBox(height: 20),

                            Text(
                              "Room No: $roomNumber",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 15),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hospital: $hospitalName",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Status: Occupied",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Allocated At: $allocatedAt",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
