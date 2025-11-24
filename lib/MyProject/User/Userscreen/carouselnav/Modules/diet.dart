import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DietScreen extends StatelessWidget {
  final String userId;
  final String hospitalId;

  DietScreen({super.key, required this.userId, required this.hospitalId});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref("users/$userId/diet");

    return Scaffold(
      appBar: AppBar(title: Text("Diet Plan")),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No diet plan found"));
          }
          final raw = snapshot.data!.snapshot.value;

          List<Map<String, dynamic>> dietList = [];

          //----------handling map------------\\
          if (raw is Map) {
            raw.forEach((key, value) {
              if (value is Map) {
                dietList.add(Map<String, dynamic>.from(value));
              }
            });
          }
          //-------- handle list-------------\\
          else if (raw is List) {
            for (var value in raw) {
              if (value is Map) {
                dietList.add(Map<String, dynamic>.from(value));
              }
            }
          }
          if (dietList.isEmpty) {
            return const Center(child: Text("No diet plan found"));
          }

          return ListView.builder(
            itemCount: dietList.length,
            itemBuilder: (context, index) {
              final meal = dietList[index];
              return Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.green.shade700, Colors.green.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Card(
                  color: Colors.transparent,
                  elevation: 0,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(meal["dietPlan"] ?? "No details"),
                    leading: Icon(Icons.restaurant_menu, color: Colors.white),
                    subtitle: Text(
                      "Doctor: ${meal["doctorName"] ?? "Unknown"}\nHospital: ${meal["hospitalName"] ?? "Unknown"}",
                      style: TextStyle(color: Colors.white70),
                    ),
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
