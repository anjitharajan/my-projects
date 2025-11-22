import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserMapScreen extends StatefulWidget {
  final String hospitalId;
  const UserMapScreen({super.key, required this.hospitalId});

  @override
  State<UserMapScreen> createState() => _UserMapScreenState();
}

class _UserMapScreenState extends State<UserMapScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  Map<String, String> floorMaps = {};

  @override
  void initState() {
    super.initState();
    _loadFloorMaps();
  }

  void _loadFloorMaps() {
    dbRef.child("hospitals/${widget.hospitalId}/services/map").onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          floorMaps = data.map((key, value) => MapEntry(key, value['url'].toString()));
        });
      } else {
        setState(() => floorMaps = {});
      }
    });
  }

  void _openFloorMap(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Floor Map")),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(url),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hospital Floor Maps")),
      body: floorMaps.isEmpty
          ? const Center(child: Text("No floor maps uploaded yet."))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: floorMaps.entries.map((entry) {
                final floorName = entry.key;
                final url = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(floorName),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openFloorMap(url),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
