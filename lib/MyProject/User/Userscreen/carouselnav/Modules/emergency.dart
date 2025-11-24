import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EmergencyScreen extends StatefulWidget {
  final String hospitalId;
  final String userId;

  const EmergencyScreen({
    super.key,
    required this.hospitalId,
    required this.userId,
  });

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String userName = "";
  String roomNumber = "";
  String phoneNumber = "";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final snap = await dbRef.child("users/${widget.userId}").get();

    if (snap.exists) {
      setState(() {
        userName = snap.child("name").value?.toString() ?? "Unknown User";
        roomNumber =
            snap.child("roomNumber").value?.toString() ?? "Not Assigned";
        phoneNumber = snap.child("phone").value?.toString() ?? "No Phone";
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  Future<void> _sendEmergency() async {
    final String eKey = DateTime.now().millisecondsSinceEpoch.toString();

    //-------------save under user node--------------------\\
    await dbRef.child("users/${widget.userId}/emergencies/$eKey").set({
      "title": _titleController.text,
      "message": _descController.text,
      "timestamp": DateTime.now().toString(),
      "status": "pending",
      "hospitalId": widget.hospitalId,
    });

    //--------save under hospital node--------------------\\
    await dbRef
        .child("hospitals/${widget.hospitalId}/services/emergencies/$eKey")
        .set({
          "title": _titleController.text,
          "message": _descController.text,
          "timestamp": DateTime.now().toString(),
          "status": "pending",
          "userId": widget.userId,
          "userName": userName,
          "roomNumber": roomNumber,
          "phone": phoneNumber,
        });

    _titleController.clear();
    _descController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency"),
        backgroundColor: Colors.redAccent,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.warning),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Raise Emergency"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _sendEmergency();
                    Navigator.pop(context);
                  },
                  child: const Text("Send"),
                ),
              ],
            ),
          );
        },
      ),

      body: StreamBuilder(
        stream: dbRef
            .child("users/${widget.userId}/emergencies")
            .onValue, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No emergencies submitted yet."));
          }

          final rawData = snapshot.data!.snapshot.value as Map;
          final emergencies = rawData.entries.toList()
            ..sort(
              (a, b) => b.value['timestamp'].toString().compareTo(
                a.value['timestamp'].toString(),
              ),
            );

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: emergencies.length,
            itemBuilder: (context, index) {
              final e = Map<String, dynamic>.from(emergencies[index].value);
              final status = e['status'] ?? "pending";

              return Card(
                color: status == "attended"
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    e['title'] ?? "Emergency",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Message: ${e['message'] ?? ''}"),
                      const SizedBox(height: 4),
                      Text("Time: ${e['timestamp']}"),
                      const SizedBox(height: 6),
                      Text(
                        "Status: ${status.toUpperCase()}",
                        style: TextStyle(
                          color: status == "attended"
                              ? Colors.green
                              : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
