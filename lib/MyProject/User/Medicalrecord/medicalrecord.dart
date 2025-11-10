import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MedicalRecordPage extends StatelessWidget {
  final String userId;
  const MedicalRecordPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref("Users/$userId/medicalRecords");

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Medical Records"),
        backgroundColor: const Color(0xFF043051),
        elevation: 2,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(
              child: Text(
                "No medical records found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final data =
              Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          final records = data.entries.toList()
            ..sort((a, b) => b.value["timestamp"]
                .toString()
                .compareTo(a.value["timestamp"].toString())); // latest first

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final rec = Map<String, dynamic>.from(records[index].value);
              final imageUrl = rec["imageUrl"] ?? "";
              final localImagePath = rec["imagePath"] ?? "";
              final timestamp = rec["timestamp"] ?? "";

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF043051).withOpacity(0.1),
                    child: const Icon(
                      Icons.local_hospital,
                      color: Color(0xFF043051),
                      size: 26,
                    ),
                  ),
                  title: Text(
                    rec["doctorName"] ?? "Unknown Doctor",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF043051),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec["hospitalName"] ?? "Unknown Hospital",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Prescription: ${rec["prescription"] ?? "Not provided"}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Date: ${timestamp.toString().split('T').first}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: _buildImagePreview(imageUrl, localImagePath),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Helper to show image (network or local)
  Widget _buildImagePreview(String imageUrl, String localImagePath) {
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.receipt_long,
            color: Colors.grey,
            size: 30,
          ),
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
