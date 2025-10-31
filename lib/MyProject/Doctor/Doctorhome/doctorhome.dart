import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

class DoctorDashboard extends StatefulWidget {
  final String doctorId;
  DoctorDashboard({super.key, required this.doctorId});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final dbRef = FirebaseDatabase.instance.ref();
  final ImagePicker _picker = ImagePicker();

  Future<void> _addPrescription({
    required String appointmentId,
    required String userId,
    required String userName,
    required String doctorName,
    required String hospitalName,
  }) async {
    final TextEditingController prescriptionController =
        TextEditingController();
    XFile? pickedImage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Prescription"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: prescriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Enter prescription details",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    if (pickedImage != null)
                      Image.file(File(pickedImage!.path), height: 120),
                    SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final img = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (img != null) setState(() => pickedImage = img);
                      },
                      icon: Icon(Icons.photo),
                      label: Text("Upload Image"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String? imageUrl;
                    if (pickedImage != null) {
                      final file = File(pickedImage!.path);
                    }
                    await dbRef
                        .child(
                          "Doctors/${widget.doctorId}/appointments/$appointmentId",
                        )
                        .update({
                          "prescription": prescriptionController.text,
                          "imageUrl": imageUrl ?? "",
                          "status": "Completed",
                        });
                    final recordRef = dbRef
                        .child("Users/$userId/medicalRecords")
                        .push();
                    await recordRef.set({
                      "doctorName": doctorName,
                      "hospitalName": hospitalName,
                      "prescription": prescriptionController.text,
                      "imageUrl": imageUrl ?? "",
                      "timestamp": DateTime.now().toIso8601String(),
                    });
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsRef = dbRef.child(
      "Doctors/${widget.doctorId}/appointments",
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor Dashboard (${widget.doctorId})"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: StreamBuilder(
        stream: appointmentsRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return Center(child: Text("No appointments yet"));
          }
          final data = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );
          final appts = data.entries.toList();
          return ListView.builder(
            itemCount: appts.length,
            itemBuilder: (context, index) {
              final appt = Map<String, dynamic>.from(appts[index].value);
              final appointmentId = appts[index].key;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: Colors.blue),
                  title: Text(appt["userName"] ?? "Unknown User"),
                  subtitle: Text("${appt["date"]} • ${appt["time"]}"),
                  trailing: Text(
                    appt["status"] ?? "Pending",
                    style: TextStyle(
                      color: (appt["status"] == "Completed")
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  onTap: () {
                    _addPrescription(
                      appointmentId: appointmentId,
                      userId: appt["userId"],
                      userName: appt["userName"],
                      doctorName: widget.doctorId,
                      hospitalName: appt["hospitalName"],
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
