import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class RequestScreen extends StatefulWidget {
  final String hospitalId;
  final String userId;

  const RequestScreen({
    super.key,
    required this.hospitalId,
    required this.userId,
  });

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    _listenToRequests();
  }

  void _listenToRequests() {
    dbRef
        .child("hospitals/${widget.hospitalId}/services/requests")
        .onValue
        .listen((event) {
          final data = event.snapshot.value;
          if (data != null && data is Map) {
            setState(() {
              requests = data.entries
                  .map((e) {
                    final value = Map<String, dynamic>.from(e.value);
                    value["requestId"] = e.key;
                    return value;
                  })
                  .where((r) => r["userId"] == widget.userId)
                  .toList();

              requests.sort((a, b) {
                final aTime =
                    DateTime.tryParse(a["timestamp"] ?? "") ?? DateTime(0);
                final bTime =
                    DateTime.tryParse(b["timestamp"] ?? "") ?? DateTime(0);
                return bTime.compareTo(aTime);
              });
            });
          } else {
            setState(() => requests = []);
          }
        });
  }

  void _addRequest(
    String message,
    String userName,
    String userPhone, {
    String? roomNumber,
  }) {
    final newRequestId = const Uuid().v4();
    final timestamp = DateTime.now().toIso8601String();

    final newRequest = {
      "requestId": newRequestId,
      "userId": widget.userId,
      "userName": userName,
      "userPhone": userPhone,
      "message": message,
      "roomNumber": roomNumber ?? "",
      "status":
          "Pending", //<<<<---hospital can update this to accepted or not---\\
      "timestamp": timestamp,
    };

    dbRef
        .child("hospitals/${widget.hospitalId}/services/requests/$newRequestId")
        .set(newRequest)
        .then((_) => Navigator.of(context).pop())
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to add request: $error")),
          );
        });
  }

  void _showAddRequestDialog() {
    final _messageController = TextEditingController();
    final _roomController = TextEditingController();
    final _nameController = TextEditingController();
    final _phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Request"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Your Name"),
              ),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: "Message"),
              ),
              TextField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: "Room Number (optional)",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_messageController.text.trim().isEmpty ||
                  _nameController.text.trim().isEmpty ||
                  _phoneController.text.trim().isEmpty)
                return;

              _addRequest(
                _messageController.text.trim(),
                _nameController.text.trim(),
                _phoneController.text.trim(),
                roomNumber: _roomController.text.trim().isEmpty
                    ? null
                    : _roomController.text.trim(),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Requests"),
        backgroundColor: const Color(0xFF043051),
      ),
      body: requests.isEmpty
          ? const Center(child: Text("No requests yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                final status = req["status"] ?? "Pending";
                List<Color> gradientColors;
                if (status == "Resolved") {
                  gradientColors = [
                    Colors.green.shade300,
                    Colors.green.shade700,
                  ];
                } else if (status == "Accepted") {
                  gradientColors = [Colors.blue.shade300, Colors.blue.shade700];
                } else {
                  gradientColors = [
                    Colors.orange.shade300,
                    Colors.orange.shade700,
                  ];
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 25,
                        horizontal: 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Icon(
                              Icons.request_page,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            req["message"] ?? "No message",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          if (req["userName"] != null)
                            Text(
                              "Name: ${req["userName"]}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          if (req["userPhone"] != null)
                            Text(
                              "Phone: ${req["userPhone"]}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          if (req["roomNumber"] != null &&
                              req["roomNumber"].toString().isNotEmpty)
                            Text(
                              "Room: ${req["roomNumber"]}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          if (req["timestamp"] != null)
                            Text(
                              "Time: ${req["timestamp"]}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          Text(
                            "Status: $status",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          if (status == "Accepted")
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Accepted by Hospital",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRequestDialog,
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF043051),
      ),
    );
  }
}
