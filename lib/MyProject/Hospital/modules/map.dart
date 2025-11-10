import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MapServicePage extends StatefulWidget {
  final String hospitalId;
  const MapServicePage({super.key, required this.hospitalId});

  @override
  State<MapServicePage> createState() => _MapServicePageState();
}

class _MapServicePageState extends State<MapServicePage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage storage = FirebaseStorage.instance;
  String? mapUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentMap();
  }

  /// 🔹 Load current map URL from Realtime DB
  void _loadCurrentMap() {
    dbRef.child("hospitals/${widget.hospitalId}/services/map/url").onValue.listen((event) {
      setState(() {
        mapUrl = event.snapshot.value?.toString();
      });
    });
  }

  /// 🔹 Pick an image from gallery
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => isLoading = true);
    final file = File(picked.path);

    try {
      final ref = storage.ref().child("hospital_maps/${widget.hospitalId}.jpg");
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await dbRef.child("hospitals/${widget.hospitalId}/services/map").set({
        "url": url,
        "uploadedAt": DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Map uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading map: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 🔹 Delete the map (optional)
  Future<void> _deleteMap() async {
    if (mapUrl == null) return;
    try {
      await storage.ref().child("hospital_maps/${widget.hospitalId}.jpg").delete();
    } catch (_) {}
    await dbRef.child("hospitals/${widget.hospitalId}/services/map").remove();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Map deleted successfully.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hospital Floor Map"),
        backgroundColor: const Color.fromARGB(255, 4, 46, 81),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: "Upload / Replace Map",
            onPressed: _pickAndUploadImage,
          ),
          if (mapUrl != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              tooltip: "Delete Map",
              onPressed: _deleteMap,
            ),
        ],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : mapUrl == null
                ? const Text("No map uploaded yet.")
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Current Floor Map",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            mapUrl!,
                            height: 300,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const CircularProgressIndicator();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
