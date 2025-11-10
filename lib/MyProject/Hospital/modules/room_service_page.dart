import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RoomServicePage extends StatefulWidget {
  final String hospitalId;
  const RoomServicePage({super.key, required this.hospitalId});

  @override
  State<RoomServicePage> createState() => _RoomServicePageState();
}

class _RoomServicePageState extends State<RoomServicePage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final TextEditingController roomNumberController = TextEditingController();
  List<Map<String, dynamic>> rooms = [];
  List<Map<String, dynamic>> connectedUsers = [];

  @override
  void initState() {
    super.initState();
    _listenToRooms();
    _listenToConnectedUsers();
  }

  void _listenToRooms() {
    dbRef.child("hospitals/${widget.hospitalId}/services/rooms").onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          rooms = data.entries.map((e) {
            final value = Map<String, dynamic>.from(e.value);
            value["roomId"] = e.key;
            return value;
          }).toList();
        });
      } else {
        setState(() => rooms = []);
      }
    });
  }

  void _listenToConnectedUsers() {
    dbRef.child("hospitals/${widget.hospitalId}/connectedUsers").onValue.listen((event) async {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        List<Map<String, dynamic>> temp = [];
        for (final uid in data.keys) {
          final userSnap = await dbRef.child("users/$uid").get();
          if (userSnap.exists) {
            final userData = Map<String, dynamic>.from(userSnap.value as Map);
            temp.add({
              "userId": uid,
              "name": userData["name"] ?? "Unknown",
            });
          }
        }
        setState(() => connectedUsers = temp);
      } else {
        setState(() => connectedUsers = []);
      }
    });
  }

  Future<void> _addRoom() async {
    final roomNumber = roomNumberController.text.trim();
    if (roomNumber.isEmpty) return;

    final newRef = dbRef.child("hospitals/${widget.hospitalId}/services/rooms").push();
    await newRef.set({
      "roomNumber": roomNumber,
      "assignedUserId": null,
      "assignedUserName": null,
    });
    roomNumberController.clear();
  }

  Future<void> _deleteRoom(String roomId) async {
    await dbRef.child("hospitals/${widget.hospitalId}/services/rooms/$roomId").remove();
  }

  Future<void> _assignRoom(String roomId, String userId, String userName) async {
    await dbRef.child("hospitals/${widget.hospitalId}/services/rooms/$roomId").update({
      "assignedUserId": userId,
      "assignedUserName": userName,
    });

    await dbRef.child("users/$userId").update({
      "connectedHospitalId": widget.hospitalId,
      "roomAssigned": roomId,
    });
  }

  Future<void> _unassignRoom(String roomId, String userId) async {
    await dbRef.child("hospitals/${widget.hospitalId}/services/rooms/$roomId").update({
      "assignedUserId": null,
      "assignedUserName": null,
    });

    await dbRef.child("users/$userId/roomAssigned").remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Rooms"),
        backgroundColor: const Color.fromARGB(255, 4, 46, 81),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: roomNumberController,
                    decoration: const InputDecoration(
                      labelText: "Enter Room Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 4, 46, 81),
                  ),
                  child: const Text("Add Room"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: rooms.isEmpty
                  ? const Center(child: Text("No rooms added yet."))
                  : ListView.builder(
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        final assigned = room["assignedUserId"] != null;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.meeting_room),
                            title: Text("Room ${room["roomNumber"]}"),
                            subtitle: assigned
                                ? Text("Assigned to: ${room["assignedUserName"]}")
                                : const Text("Not assigned"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!assigned)
                                  PopupMenuButton(
                                    icon: const Icon(Icons.person_add),
                                    itemBuilder: (context) {
                                      return connectedUsers.map((user) {
                                        return PopupMenuItem(
                                          value: user,
                                          child: Text(user["name"]),
                                        );
                                      }).toList();
                                    },
                                    onSelected: (user) => _assignRoom(
                                      room["roomId"],
                                      user["userId"],
                                      user["name"],
                                    ),
                                  ),
                                if (assigned)
                                  IconButton(
                                    icon: const Icon(Icons.person_remove),
                                    onPressed: () => _unassignRoom(
                                      room["roomId"],
                                      room["assignedUserId"],
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteRoom(room["roomId"]),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
