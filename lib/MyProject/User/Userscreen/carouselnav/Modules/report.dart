import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  final String hospitalId;

  ReportScreen({super.key, required this.hospitalId});

  @override
  Widget build(BuildContext context) {
    final reports = [
      {"title": "Blood Test", "date": "2025-10-28"},
      {"title": "MRI Scan", "date": "2025-10-25"},
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Medical Reports")),
      body: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final rep = reports[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(Icons.insert_drive_file, color: Colors.blueAccent),
              title: Text(rep["title"]!),
              subtitle: Text("Date: ${rep["date"]}"),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
            ),
          );
        },
      ),
    );
  }
}
