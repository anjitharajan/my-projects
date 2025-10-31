import 'package:flutter/material.dart';

class EmergencyScreen extends StatelessWidget {
  final String hospitalId;

   EmergencyScreen({super.key, required this.hospitalId});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {"name": "Emergency Desk", "phone": "+91 99999 11111"},
      {"name": "Ambulance", "phone": "+91 99999 22222"},
    ];

    return Scaffold(
      appBar: AppBar(title:  Text("Emergency Contacts")),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Card(
            margin:  EdgeInsets.all(8),
            child: ListTile(
              leading:  Icon(Icons.phone_in_talk, color: Colors.redAccent),
              title: Text(contact["name"]!),
              subtitle: Text(contact["phone"]!),
              trailing: IconButton(
                icon:  Icon(Icons.call, color: Colors.green),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}
