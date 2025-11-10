import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EmergencyServicePage extends StatefulWidget {
  final String hospitalId;

  const EmergencyServicePage({super.key, required this.hospitalId});

  @override
  State<EmergencyServicePage> createState() => _EmergencyServicePageState();
}

class _EmergencyServicePageState extends State<EmergencyServicePage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Alerts"),
        backgroundColor: const Color.fromARGB(255, 4, 46, 81),
      ),
      body: StreamBuilder(
        stream:
            dbRef.child("hospitals/${widget.hospitalId}/emergencies").onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No emergency alerts yet."));
          }

          final data = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
          final emergencies = data.entries.toList()
            ..sort((a, b) => b.value['timestamp']
                .toString()
                .compareTo(a.value['timestamp'].toString())); // latest first

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: emergencies.length,
            itemBuilder: (context, index) {
              final eKey = emergencies[index].key;
              final e = Map<String, dynamic>.from(emergencies[index].value);

              return Card(
                color: e['status'] == 'attended'
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(
                    Icons.emergency,
                    color: e['status'] == 'attended'
                        ? Colors.green
                        : Colors.redAccent,
                  ),
                  title: Text(
                    e['userName'] ?? "Unknown User",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Room: ${e['roomNumber'] ?? '-'}"),
                      Text("Message: ${e['message'] ?? 'No message'}"),
                      Text("Time: ${e['timestamp'] ?? ''}"),
                      Text(
                        "Status: ${e['status'] ?? 'pending'}",
                        style: TextStyle(
                          color: e['status'] == 'attended'
                              ? Colors.green
                              : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'attend') {
                        await dbRef
                            .child(
                                "hospitals/${widget.hospitalId}/emergencies/$eKey/status")
                            .set('attended');
                      } else if (value == 'delete') {
                        await dbRef
                            .child(
                                "hospitals/${widget.hospitalId}/emergencies/$eKey")
                            .remove();
                      }
                    },
                    itemBuilder: (context) => [
                      if (e['status'] != 'attended')
                        const PopupMenuItem(
                          value: 'attend',
                          child: Text("Mark as Attended"),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text("Delete Alert"),
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
