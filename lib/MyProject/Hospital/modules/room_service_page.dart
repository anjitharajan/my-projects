import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class HospitalRoomPage extends StatefulWidget {
  final String hospitalId;

  const HospitalRoomPage({super.key, required this.hospitalId});

  @override
  State<HospitalRoomPage> createState() => _HospitalRoomPageState();
}

class _HospitalRoomPageState extends State<HospitalRoomPage> {
  final DatabaseReference db = FirebaseDatabase.instance.ref();
  final TextEditingController roomController = TextEditingController();

  List<Map<String, dynamic>> rooms = [];
  List<Map<String, dynamic>> enabledUsers = [];
  bool loading = true;

@override
void initState() {
  super.initState();
  initLoad();
}

Future<void> initLoad() async {
  await loadRooms();
  await loadEnabledUsers();
  setState(() => loading = false);
}

  // ---------------- LOAD ROOMS ----------------\\
Future<void> loadRooms() async {
  final snap =
      await db.child("hospitals/${widget.hospitalId}/rooms").get();

  rooms.clear();

  if (snap.exists) {
    for (var child in snap.children) {
      final value = child.value;

      if (value is Map) {
        final data = Map<String, dynamic>.from(value);
        rooms.add(data);
      }
      // If it's bool or something else, skip it
    }
  }
}

  // ---------------- LOAD ENABLED USERS ----------------\\
Future<void> loadEnabledUsers() async {
  final snap = await db
      .child("hospitals/${widget.hospitalId}/connectedUsers")
      .get();

  enabledUsers.clear();

  if (snap.exists) {
    for (var child in snap.children) {
      String userId = child.key!;

      // ✅ Fetch from actual user node
      final userData =
          await db.child("users/$userId").get();

      String name = userData.child("name").value?.toString() ?? "Unknown User";

      final userSnap = await db.child("users/$userId/allocatedRoom").get();

      enabledUsers.add({
        "userId": userId,
        "name": name,
        "hasRoom": userSnap.exists,
      });
    }
  }

  setState(() {});
}

  // ---------------- ADD ROOM ----------------\\
 Future<void> addRoom() async {
  if (roomController.text.trim().isEmpty) return;

  String roomId = const Uuid().v4();

  final roomData = {
    "roomId": roomId,
    "roomNumber": roomController.text.trim(),
    "status": "available",
    "allocatedTo": "",
  };

  // ✔ Save ONLY inside hospital node
  await db.child("hospitals/${widget.hospitalId}/rooms/$roomId").set(roomData);

  roomController.clear();
  await loadRooms();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Room added successfully")),
  );
}

  // ---------------- ALLOCATE ROOM --------------\\
Future<void> allocateRoom(String roomId, String roomNumber) async {
  // STEP 1 — Select user
  String? userId = await showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text("Allocate Room To"),

    content: SizedBox(
      width: 300,               
      height: 300,             
      child: enabledUsers.isEmpty
          ? const Center(
              child: Text("No eligible users available"),
            )
          : ListView.builder(
              shrinkWrap: true, // ✅ FIX: Prevent size issues
              itemCount: enabledUsers.length,
              itemBuilder: (context, index) {
                final u = enabledUsers[index];

                return ListTile(
                  title: Text(u["name"]),
                  subtitle: u["hasRoom"]
                      ? const Text(
                          "Already has a room",
                          style: TextStyle(color: Colors.red),
                        )
                      : null,
                  onTap: u["hasRoom"]
                      ? null
                      : () => Navigator.pop(context, u["userId"]),
                );
              },
            ),
    ),

    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Cancel"),
      )
    ],
  ),
);
if (userId == null) return; 


  // STEP 2 — Show loading barrier
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // Ensure room exists
    final snap = await db
        .child("hospitals/${widget.hospitalId}/rooms/$roomId")
        .get()
        .timeout(const Duration(seconds: 5));

    if (!snap.exists) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Room not found in hospital")),
      );
      return;
    }
// FETCH USER NAME
final userSnap = await db.child("users/$userId/name").get();
String userName = userSnap.value?.toString() ?? "Unknown";

    // UPDATE ROOM
  await db
    .child("hospitals/${widget.hospitalId}/rooms/$roomId")
    .update({
  "status": "occupied",
  "allocatedToId": userId,
  "allocatedToName": userName,
});


    // MIRROR TO USER
    await db.child("users/$userId/allocatedRoom").set({
      "hospitalId": widget.hospitalId,
      "roomId": roomId,
      "roomNumber": roomNumber,
      "allocatedAt": DateTime.now().toIso8601String(),
    });

    Navigator.pop(context); // CLOSE LOADING

    await loadRooms();
    await loadEnabledUsers();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Room allocated successfully")),
    );
  } catch (e) {
    Navigator.pop(context); // ENSURE ALWAYS CLOSES
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}



  // ---------------- DEALLOCATE ROOM ----------------\\
Future<void> deallocateRoom(String roomId, String userId) async {
  // ✔ Update room inside hospital node
  await db.child("hospitals/${widget.hospitalId}/rooms/$roomId").update({
    "status": "available",
    "allocatedTo": "",
  });

  // ✔ Remove from user side
if (userId.isNotEmpty) {
  await db.child("users/$userId/allocatedRoom").remove();
}

  await loadRooms();
  await loadEnabledUsers();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Room deallocated")));
}


  // ---------------- UI BUILDER ----------------\\
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
        title: Text(
          "Hospital Rooms",
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,

        backgroundColor: Colors.transparent,
        elevation: 0,

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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                children: [
                  // ADD ROOM TEXTFIELD
                  Container(
                     padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.blue,
                      Color.fromARGB(255, 4, 46, 81),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                      child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: roomController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Room Number",
                          labelStyle: GoogleFonts.dmSerifDisplay(
                            fontSize: 19,
                            color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: addRoom,
                          style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color.fromARGB(255, 4, 46, 81),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                          child:  Text("Add",
                             style: GoogleFonts.germaniaOne(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 20),
                  // ROOM LIST
                  Expanded(
                    child: ListView.builder(
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        bool isAvailable = room["status"] == "available";
                        String allocatedUser = room["allocatedTo"] ?? "";
            
                       return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.blue,
                            Color.fromARGB(255, 4, 46, 81),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),

                        title: Text(
                          "Room No: ${room["roomNumber"]}",
                          style: GoogleFonts.dmSerifDisplay(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            "Status : ${room["status"]}\n"
                            "Allocated To : ${room["allocatedToName"] ?? "None"}",
                            style: GoogleFonts.neuton(
                              color: Colors.white70,
                              fontSize: 18,
                              height: 1.4,
                            ),
                          ),
                        ),
                              trailing: isAvailable
                                  ? ElevatedButton(
                                      onPressed: () => allocateRoom(
                                        room["roomId"],
                                        room["roomNumber"],
                                      ),
                                         style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor:
                                      Color.fromARGB(255, 4, 46, 81),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                      child:  Text("Allocate",
                                      style: GoogleFonts.germaniaOne(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ))
                                  : ElevatedButton(
                                     
                                      onPressed: () => deallocateRoom(
                                        room["roomId"],
                                        allocatedUser,
                                      ),
                                        style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                      child:  Text("Free Room",
                                        style: GoogleFonts.germaniaOne(
                                        fontSize: 16
                                      ),),
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
