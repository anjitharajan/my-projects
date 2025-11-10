import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RequestServicePage extends StatefulWidget {
  final String hospitalId;
  const RequestServicePage({super.key, required this.hospitalId});

  @override
  State<RequestServicePage> createState() => _RequestServicePageState();
}

class _RequestServicePageState extends State<RequestServicePage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    _listenToRequests();
  }

  void _listenToRequests() {
    dbRef.child("hospitals/${widget.hospitalId}/services/requests").onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          requests = data.entries.map((e) {
            final value = Map<String, dynamic>.from(e.value);
            value["requestId"] = e.key;
            return value;
          }).toList();

          // Sort by latest first
          requests.sort((a, b) {
            final aTime = DateTime.tryParse(a["timestamp"] ?? "") ?? DateTime(0);
            final bTime = DateTime.tryParse(b["timestamp"] ?? "") ?? DateTime(0);
            return bTime.compareTo(aTime);
          });
        });
      } else {
        setState(() => requests = []);
      }
    });
  }

  Future<void> _markResolved(String requestId) async {
    await dbRef
        .child("hospitals/${widget.hospitalId}/services/requests/$requestId")
        .update({"status": "Resolved"});
  }

  Future<void> _deleteRequest(String requestId) async {
    await dbRef
        .child("hospitals/${widget.hospitalId}/services/requests/$requestId")
        .remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Requests"),
        backgroundColor: const Color.fromARGB(255, 4, 46, 81),
      ),
      body: requests.isEmpty
          ? const Center(child: Text("No requests yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                final status = req["status"] ?? "Pending";

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: status == "Resolved"
                          ? Colors.green
                          : Colors.orange,
                      child: Icon(
                        status == "Resolved"
                            ? Icons.check
                            : Icons.pending_actions,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(req["message"] ?? "No message"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (req["userName"] != null)
                          Text("User: ${req["userName"]}"),
                        if (req["roomNumber"] != null)
                          Text("Room: ${req["roomNumber"]}"),
                        if (req["timestamp"] != null)
                          Text(
                            "Time: ${req["timestamp"]}",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (status != "Resolved")
                          IconButton(
                            icon: const Icon(Icons.done, color: Colors.green),
                            tooltip: "Mark as Resolved",
                            onPressed: () => _markResolved(req["requestId"]),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: "Delete Request",
                          onPressed: () => _deleteRequest(req["requestId"]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
