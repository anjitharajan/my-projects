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
  final Set<String> seenKeys = {};

  @override
  void initState() {
    super.initState();

    //------------------ Showing realtime notifications from the user side -------------------------\\
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dbRef
          .child("hospitals/${widget.hospitalId}/services/emergencies")
          .onChildAdded
          .listen((event) {
            final eKey = event.snapshot.key;
            if (eKey == null || seenKeys.contains(eKey)) return;

            seenKeys.add(eKey);

            final data = event.snapshot.value as Map?;
            if (data == null) return;

            final e = Map<String, dynamic>.from(data);

            final userName = e['userName'] ?? "Unknown User";
            final message = e['message'] ?? "No message";

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(" Emergency from $userName: $message"),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 3),
              ),
            );
          });
    });
  }

  //--------------- emergency from hospital/service/emergencies---------------------\\
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Alerts"),
        backgroundColor: const Color.fromARGB(255, 4, 46, 81),
      ),
      body: StreamBuilder(
        stream: dbRef
            .child("hospitals/${widget.hospitalId}/services/emergencies")
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No emergency alerts yet."));
          }

          final rawData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final data = Map<String, dynamic>.from(rawData);

          final emergencies = data.entries.toList()
            ..sort(
              (a, b) => b.value['timestamp'].toString().compareTo(
                a.value['timestamp'].toString(),
              ),
            );

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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.emergency,
                    color: e['status'] == 'attended'
                        ? Colors.green
                        : Colors.redAccent,
                  ),

                  title: Text(
                    e['title'] ?? "Emergency",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("User: ${e['userName'] ?? '-'}"),
                      Text("Room: ${e['roomNumber'] ?? '-'}"),
                      Text("Phone: ${e['phone'] ?? '-'}"),
                      const SizedBox(height: 4),
                      Text(
                        "Message: ${e['message'] ?? 'No message'}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text("Time: ${e['timestamp'] ?? ''}"),
                      const SizedBox(height: 4),
                      Text(
                        "Status: ${e['status'] ?? 'pending'}",
                        style: TextStyle(
                          color: e['status'] == 'attended'
                              ? Colors.green
                              : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'attend') {
                        //--------Update hospital node from user side-------------\\
                        await dbRef
                            .child(
                              "hospitals/${widget.hospitalId}/services/emergencies/$eKey/status",
                            )
                            .set('attended');

                        //---------------- Get userid to update user node -----------------\\
                        final userIdSnap = await dbRef
                            .child(
                              "hospitals/${widget.hospitalId}/services/emergencies/$eKey/userId",
                            )
                            .get();

                        if (userIdSnap.exists) {
                          final userId = userIdSnap.value.toString();

                          //------------------Update user emergency satus node back-------------\\
                          await dbRef
                              .child("users/$userId/emergencies/$eKey/status")
                              .set("attended");
                        }

                        //------------------- remove emergency-----------------------\\
                      } else if (value == 'delete') {
                        await dbRef
                            .child(
                              "hospitals/${widget.hospitalId}/services/emergencies/$eKey",
                            )
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
