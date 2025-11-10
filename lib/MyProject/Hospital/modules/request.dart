import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RequestServicePage extends StatefulWidget {
  final String hospitalId;

  const RequestServicePage({super.key, required this.hospitalId});

  @override
  State<RequestServicePage> createState() => _RequestServicePageState();
}

class _RequestServicePageState extends State<RequestServicePage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Requests"),
        backgroundColor: const Color.fromARGB(255, 4, 46, 81),
      ),
      body: StreamBuilder(
        stream:
            dbRef.child("hospitals/${widget.hospitalId}/requests").onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No requests yet."));
          }

          final data = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
          final requests = data.entries.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final reqKey = requests[index].key;
              final req = Map<String, dynamic>.from(requests[index].value);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    req['userName'] ?? "Unknown User",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Room: ${req['roomNumber'] ?? '-'}"),
                      Text("Message: ${req['message'] ?? '-'}"),
                      Text(
                        "Status: ${req['status'] ?? 'pending'}",
                        style: TextStyle(
                          color: (req['status'] == 'resolved')
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      Text(
                        "Time: ${req['timestamp'] ?? ''}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'resolve') {
                        await dbRef
                            .child(
                                "hospitals/${widget.hospitalId}/requests/$reqKey/status")
                            .set('resolved');
                      } else if (value == 'delete') {
                        await dbRef
                            .child(
                                "hospitals/${widget.hospitalId}/requests/$reqKey")
                            .remove();
                      }
                    },
                    itemBuilder: (context) => [
                      if (req['status'] != 'resolved')
                        const PopupMenuItem(
                          value: 'resolve',
                          child: Text("Mark as Resolved"),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text("Delete Request"),
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
