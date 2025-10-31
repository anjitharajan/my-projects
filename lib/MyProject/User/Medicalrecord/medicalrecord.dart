import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MedicalRecordPage extends StatelessWidget {
  final String userId;
  MedicalRecordPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref("Users/$userId/medicalRecords");

    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text("Medical Records"),
        backgroundColor: Color(0xFF043051),
        elevation: 2,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return Center(
              child: Text(
                "No medical records found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final data = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );
          final records = data.values.toList();

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final rec = Map<String, dynamic>.from(records[index]);

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF043051).withOpacity(0.1),
                    child: Icon(
                      Icons.local_hospital,
                      color: Color(0xFF043051),
                      size: 28,
                    ),
                  ),
                  title: Text(
                    rec["doctorName"] ?? "Unknown Doctor",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF043051),
                    ),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${rec["hospitalName"] ?? "N/A"}",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Prescription: ${rec["prescription"] ?? "Not provided"}",
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  trailing: rec["imageUrl"] != null && rec["imageUrl"] != ""
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            rec["imageUrl"],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.receipt_long, color: Colors.grey, size: 30),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
