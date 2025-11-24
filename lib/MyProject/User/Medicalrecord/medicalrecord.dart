import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class MedicalRecordPage extends StatelessWidget {
  final String userId;

  const MedicalRecordPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref("users/$userId/medicalRecord");

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Medical Records",
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

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
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text("No medical records found"));
          }

          final raw = snapshot.data!.snapshot.value;

          //----------Filter only Map entries-----------\\
          final recordsMap = <String, Map<String, dynamic>>{};
          if (raw is Map) {
            raw.forEach((key, value) {
              if (value is Map) {
                recordsMap[key] = Map<String, dynamic>.from(value);
              }
            });
          }

          final records =
              recordsMap.entries.map((entry) {
                final rec = Map<String, dynamic>.from(entry.value);
                rec["recordId"] = entry.key;
                return rec;
              }).toList()..sort(
                (a, b) => b["date"].toString().compareTo(a["date"].toString()),
              );

          if (records.isEmpty) {
            return const Center(child: Text("No medical records found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final rec = records[index];
              final imageUrl = rec["imageUrl"] ?? "";
              final localImagePath = rec["imagePath"] ?? "";
              final date = rec["date"] ?? "";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.blue,
                        Color.fromARGB(255, 4, 46, 81),
                        // Light Blue
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(
                        Icons.local_hospital,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),

                    title: Text(
                      rec["doctorName"] ?? "Unknown Doctor",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec["hospitalName"] ?? "Unknown Hospital",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          "Prescription: ${rec["prescription"] ?? "Not provided"}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          "Date: ${date.toString().split('T').first}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),

                    trailing: _buildImagePreview(imageUrl, localImagePath),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildImagePreview(String imageUrl, String localImagePath) {
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.receipt_long, color: Colors.grey, size: 30),
        ),
      );
    } else if (localImagePath.isNotEmpty && File(localImagePath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(localImagePath),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return const Icon(Icons.receipt_long, color: Colors.grey, size: 30);
    }
  }
}
