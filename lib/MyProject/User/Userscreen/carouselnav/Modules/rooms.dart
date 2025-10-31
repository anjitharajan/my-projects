import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RoomScreen extends StatefulWidget {
  final String hospitalId;

   RoomScreen({super.key, required this.hospitalId});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final userId = FirebaseAuth.instance.currentUser?.uid;

  final List<Map<String, String>> rooms = [
    {"roomNo": "101", "type": "General", "status": "Available"},
    {"roomNo": "102", "type": "ICU", "status": "Occupied"},
    {"roomNo": "103", "type": "Deluxe", "status": "Available"},
  ];

  Future<void> bookRoom(Map<String, String> room) async {
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar( SnackBar(content: Text("User not logged in.")));
      return;
    }

    try {
      await dbRef
          .child("hospitals/${widget.hospitalId}/services/rooms/$userId")
          .set({
            "roomNo": room["roomNo"],
            "roomType": room["type"],
            "status": "Booked",
            "timestamp": DateTime.now().toIso8601String(),
          });

      await dbRef
          .child("users/$userId/servicesData/rooms/${room["roomNo"]}")
          .set({
            "hospitalId": widget.hospitalId,
            "roomType": room["type"],
            "status": "Booked",
            "timestamp": DateTime.now().toIso8601String(),
          });

      setState(() {
        room["status"] = "Booked";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Room ${room["roomNo"]} booked successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error booking room: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final rooms = [
      {"roomNo": "101", "type": "General", "status": "Available"},
      {"roomNo": "102", "type": "ICU", "status": "Occupied"},
      {"roomNo": "103", "type": "Deluxe", "status": "Available"},
    ];

    return Scaffold(
      appBar: AppBar(title:  Text("Rooms")),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return Card(
            margin:  EdgeInsets.all(8),
            child: ListTile(
              leading:  Icon(Icons.meeting_room, color: Colors.blueAccent),
              title: Text("Room ${room["roomNo"]} - ${room["type"]}"),
              subtitle: Text("Status: ${room["status"]}"),
              trailing: room["status"] == "Available"
                  ?  Icon(Icons.check_circle, color: Colors.green)
                  :  Icon(Icons.cancel, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
