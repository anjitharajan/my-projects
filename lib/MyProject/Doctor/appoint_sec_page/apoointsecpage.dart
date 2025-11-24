import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


class DoctorSecondPage extends StatefulWidget {
  final String appointmentId;
  final String userId;
  final String userName; // Patient ID
  final String doctorId;
  final String doctorName;
  final String hospitalId;
  final String hospitalName;

  const DoctorSecondPage({
    super.key,
    required this.appointmentId,
    required this.userId,
    required this.userName,
    required this.doctorId,
    required this.doctorName,
    required this.hospitalId,
    required this.hospitalName,
  });

  @override
  State<DoctorSecondPage> createState() => _DoctorSecondPageState();
}

class _DoctorSecondPageState extends State<DoctorSecondPage> {
  final db = FirebaseDatabase.instance.ref();

  final TextEditingController prescriptionController = TextEditingController();
  final TextEditingController dietController = TextEditingController();

  String? prescriptionText = "";
  String? dietText = "";
  bool loading = true;

  List<Map<String, dynamic>> prescriptions = [];
  List<Map<String, dynamic>> diets = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  // ---------------- Load from hospital side ---------------- //
  Future<void> _loadExistingData() async {
    final appointmentRef = db.child(
      "hospitals/${widget.hospitalId}/doctors/${widget.doctorId}/appointments/${widget.appointmentId}",
    );

    final snap = await appointmentRef.get();

    prescriptions.clear();
    diets.clear();

    if (snap.exists) {
      final medicalSnap = snap.child("medicalRecord");
      final dietSnap = snap.child("diet");

      // Add prescription if exists
      if (medicalSnap.exists) {
        prescriptions.add({
          "prescription": medicalSnap.child("prescription").value ?? "",
          "doctorName": medicalSnap.child("doctorName").value ?? "",
          "hospitalName": medicalSnap.child("hospitalName").value ?? "",
          "date": medicalSnap.child("date").value ?? "",
        });
      }

      // Add diet if exists
      if (dietSnap.exists) {
        diets.add({
          "dietPlan": dietSnap.child("dietPlan").value ?? "",
          "doctorName": dietSnap.child("doctorName").value ?? "",
          "hospitalName": dietSnap.child("hospitalName").value ?? "",
          "date": dietSnap.child("date").value ?? "",
        });
      }
    }

    setState(() => loading = false);
  }

  // ---------------- Save Prescription ---------------- //
  Future<void> savePrescription() async {
    final data = {
      "prescription": prescriptionController.text.trim(),
      "doctorName": widget.doctorName,
      "hospitalName": widget.hospitalName,
      "date": DateTime.now().toIso8601String(),
    };

    final appointmentId = widget.appointmentId;
    final userId = widget.userId;

    // Save inside hospital appointment
    await db
        .child(
          "hospitals/${widget.hospitalId}/doctors/${widget.doctorId}/appointments/$appointmentId/medicalRecord",
        )
        .set(data);

    // Mirror inside patient node
    await db.child("users/$userId/medicalRecord/$appointmentId").set(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Prescription saved successfully")),
    );

    prescriptionController.clear();
    await _loadExistingData(); // Refresh the list
  }

  // ---------------- Save Diet Plan ---------------- //
  Future<void> saveDiet() async {
    final data = {
      "dietPlan": dietController.text.trim(),
      "doctorName": widget.doctorName,
      "hospitalName": widget.hospitalName,
      "date": DateTime.now().toIso8601String(),
    };

    final appointmentId = widget.appointmentId;
    final userId = widget.userId;

    // 1️⃣ Save inside hospital appointment
    await db
        .child(
          "hospitals/${widget.hospitalId}/doctors/${widget.doctorId}/appointments/$appointmentId/diet",
        )
        .set(data);

    // 2️⃣ Mirror inside patient node under same appointmentId
    await db.child("users/$userId/diet/$appointmentId").set(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Diet plan saved successfully")),
    );

    dietController.clear(); // Clear input field
    await _loadExistingData(); // Refresh the list of diets
  }

  // ---------------- Build UI Section ---------------- //
  Widget _buildSection({
    required String title,
    required String? value,
    required TextEditingController controller,
    required VoidCallback onSave,
  }) {
    controller.text = value ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: null,
            decoration: InputDecoration(
              hintText: "Enter $title...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff04305A),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Save $title"),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
    Map<String, dynamic> item, {
    required bool isPrescription,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPrescription ? Colors.lightBlue[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPrescription
                ? "Prescription: ${item["prescription"]}"
                : "Diet Plan: ${item["dietPlan"]}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text("Doctor: ${item["doctorName"]}"),
          Text("Hospital: ${item["hospitalName"]}"),
          Text("Date: ${formatDate(item["date"])}"),
        ],
      ),
    );
  }
String formatDate(String dateString) {
  try {
    DateTime dt = DateTime.parse(dateString);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dt);
    String formattedTime = DateFormat('h:mm a').format(dt);
    return "$formattedDate || $formattedTime";
  } catch (e) {
    return dateString;
  }
}

  @override
  void dispose() {
    prescriptionController.dispose();
    dietController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Appointment Details",
          style: GoogleFonts.merriweather(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSection(
                    title: "Prescription",
                    value: prescriptionText,
                    controller: prescriptionController,
                    onSave: savePrescription,
                  ),
                  _buildSection(
                    title: "Diet Plan",
                    value: dietText,
                    controller: dietController,
                    onSave: saveDiet,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Saved Prescriptions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...prescriptions.map(
                    (p) => _buildListItem(p, isPrescription: true),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Saved Diet Plans",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...diets.map((d) => _buildListItem(d, isPrescription: false)),
                ],
              ),
            ),
    );
  }
}
