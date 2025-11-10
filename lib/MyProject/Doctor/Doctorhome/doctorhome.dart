import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DoctorAppointmentsPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String hospitalId;

  const DoctorAppointmentsPage({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.hospitalId,
  });

  @override
  State<DoctorAppointmentsPage> createState() => _DoctorAppointmentsPageState();
}

class _DoctorAppointmentsPageState extends State<DoctorAppointmentsPage> {
  final dbRef = FirebaseDatabase.instance.ref();

  // ------------------- Add Prescription -------------------
  Future<void> _addPrescription({
    required String appointmentId,
    required String userId,
    required String userName,
    required String hospitalName,
  }) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Prescription"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter prescription details...",
            ),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  final ref = dbRef
                      .child("Users/$userId/medicalRecords")
                      .push();
                  await ref.set({
                    "doctorId": widget.doctorId,
                    "doctorName": "Dr. ${widget.doctorName}",
                    "hospitalName": hospitalName,
                    "prescription": text,
                    "date": DateTime.now().toIso8601String(),
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // ------------------- Add Diet Plan -------------------
  Future<void> _addDietPlan({
    required String userId,
    required String userName,
    required String hospitalName,
  }) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Diet Plan"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter diet plan details..."),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  final ref = dbRef.child("Users/$userId/dietPlans").push();
                  await ref.set({
                    "doctorId": widget.doctorId,
                    "doctorName": "Dr. ${widget.doctorName}",
                    "hospitalName": hospitalName,
                    "dietPlan": text,
                    "date": DateTime.now().toIso8601String(),
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // ------------------- Cancel Appointment -------------------
  Future<void> _cancelAppointment(String appointmentId) async {
    await dbRef
        .child(
          "hospitals/${widget.hospitalId}/doctors/${widget.doctorId}/appointments/$appointmentId").remove();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Appointment cancelled"),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ------------------- UI Builder -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF043051),
        centerTitle: true,
        title: Text(
          "My Appointments - Dr. ${widget.doctorName}",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
        stream: dbRef
            .child(
              "hospitals/${widget.hospitalId}/doctors/${widget.doctorId}/appointments",
            )
            .onValue,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text("No appointments yet."));
          }

          final data = snapshot.data!.snapshot.value;

     
          if (data == null || data is! Map<dynamic, dynamic>) {
            return const Center(child: Text("No appointments yet."));
          }

          final appointments = Map<String, dynamic>.from(data);

          final apptList = appointments.entries.toList()
            ..sort((a, b) {
              final aDate =
                  DateTime.tryParse(a.value['dateTime']?.toString() ?? '') ??
                  DateTime.now();
              final bDate =
                  DateTime.tryParse(b.value['dateTime']?.toString() ?? '') ??
                  DateTime.now();
              return aDate.compareTo(bDate);
            });

          if (apptList.isEmpty) {
            return const Center(child: Text("No appointments for you yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: apptList.length,
            itemBuilder: (context, index) {
              final appt = Map<String, dynamic>.from(apptList[index].value);
              final appointmentId = apptList[index].key;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: Color(0xFF043051),
                    size: 36,
                  ),
                  title: Text(
                    appt["userName"] ?? "Unknown User",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF043051),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${appt["date"] ?? ""} • ${appt["time"] ?? ""}"),
                      if (appt["status"] != null)
                        Text(
                          "Status: ${appt["status"]}",
                          style: TextStyle(
                            color: appt["status"] == "Booked"
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (appt["userEmail"] != null)
                        Text(
                          "Email: ${appt["userEmail"]}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                    ],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'prescription') {
                            _addPrescription(
                              appointmentId: appointmentId,
                              userId: appt["userId"],
                              userName: appt["userName"],
                              hospitalName:
                                  appt["hospitalName"] ?? widget.hospitalId,
                            );
                          } else if (value == 'diet') {
                            _addDietPlan(
                              userId: appt["userId"],
                              userName: appt["userName"],
                              hospitalName:
                                  appt["hospitalName"] ?? widget.hospitalId,
                            );
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'prescription',
                            child: Text("Add Prescription"),
                          ),
                          PopupMenuItem(
                            value: 'diet',
                            child: Text("Add Diet Plan"),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _cancelAppointment(appointmentId),
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
