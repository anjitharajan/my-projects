import 'package:flutter/material.dart';

class RequestScreen extends StatelessWidget {
  final String hospitalId;

  RequestScreen({super.key, required this.hospitalId});

  @override
  Widget build(BuildContext context) {
    final requests = [
      {"title": "Nurse Assistance", "status": "Pending"},
      {"title": "Room Cleaning", "status": "Completed"},
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Requests")),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(req["title"]!),
              subtitle: Text("Status: ${req["status"]}"),
              trailing: req["status"] == "Completed"
                  ? Icon(Icons.done, color: Colors.green)
                  : Icon(Icons.access_time, color: Colors.orange),
            ),
          );
        },
      ),
    );
  }
}
