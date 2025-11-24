import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

//-------------------- inside hospital request and mapping -----------------\\
  void _listenToRequests() {
    dbRef
        .child("hospitals/${widget.hospitalId}/services/requests")
        .onValue
        .listen((event) {
          final data = event.snapshot.value;
          if (data != null && data is Map) {
            setState(() {
              requests = data.entries.map((e) {
                final value = Map<String, dynamic>.from(e.value);
                value["requestId"] = e.key;
                return value;
              }).toList();

              //------------------ Sort latest first------------------------\\
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

//--------------------mark for updation for request attended-----------------------\\
  Future<void> _markResolved(String requestId) async {
    await dbRef
        .child("hospitals/${widget.hospitalId}/services/requests/$requestId")
        .update({"status": "Resolved"});
  }
//------------------------------detele option ------------------\\
  Future<void> _deleteRequest(String requestId) async {
    await dbRef
        .child("hospitals/${widget.hospitalId}/services/requests/$requestId")
        .remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Patient Requests",
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
      body: requests.isEmpty
          ? Center(
              child: Text(
                "No requests yet...",
                style: GoogleFonts.dmSerifDisplay(fontSize: 16),
              ),
            )

            //--------- reuqst pending----------------\\
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                final status = req["status"] ?? "Pending";

      //------------------status updates after attend------------------\\
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
                        colors: status == "Resolved"
                            ? [Colors.green.shade300, Colors.green.shade700]
                            : [Colors.orange.shade300, Colors.orange.shade700],
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
                        children: [
                          Icon(
                            Icons.request_page,
                            size: 70,
                            color: Colors.white,
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
             //----------------------------- request user info--------------------\\
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (req["userName"] != null)
                                Text(
                                  "User: ${req["userName"]}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                              if (req["roomNumber"] != null)
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
                            ],
                          ),
                          const SizedBox(height: 15),

                        //----------------- action button-----------------------\\
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (status != "Resolved")
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _markResolved(req["requestId"]),
                                  icon: const Icon(Icons.done),
                                  label: const Text("Resolve"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade700,
                                  ),
                                ),
                              const SizedBox(width: 10),

                              //------------------- detele options----------------------\\
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _deleteRequest(req["requestId"]),
                                icon: const Icon(Icons.delete),
                                label: const Text("Delete"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
