import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
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
  Map<String, String> floorMaps = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFloorMaps();
  }

  //------------------- storing map node onside the hospital/service/map -----------\\
  void _loadFloorMaps() {
    dbRef.child("hospitals/${widget.hospitalId}/services/map").onValue.listen((
      event,
    ) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          floorMaps = data.map(
            (key, value) => MapEntry(key, value['base64'].toString()),
          );
        });
      } else {
        setState(() => floorMaps = {});
      }
    });
  }

  //---------------- uploading img from file floor vise ---------------\\

  Future<void> _pickAndUploadFloorMap({required String floorName}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => isLoading = true);
    try {
      final bytes = await picked.readAsBytes();
      final base64Str = base64Encode(bytes);

      await dbRef
          .child("hospitals/${widget.hospitalId}/services/map/$floorName")
          .set({
            "base64": base64Str,
            "uploadedAt": DateTime.now().toIso8601String(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$floorName map uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error uploading map: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  //--------------- delete option of map--------------\\
  void _deleteFloorMap(String floorName) async {
    await dbRef
        .child("hospitals/${widget.hospitalId}/services/map/$floorName")
        .remove();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$floorName map deleted successfully.")),
    );
  }

  // ------------view map ------------------------\\
  void _viewFloorMap(String base64Str, String floorName) {
    final bytes = base64Decode(base64Str);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(floorName)),
          body: Center(child: InteractiveViewer(child: Image.memory(bytes))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hospital Floor Map"),
        backgroundColor: const Color(0xFF043051),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Add New Floor Map"),
                    onPressed: () async {
                      final floorNameController = TextEditingController();
                      final floorName = await showDialog<String>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Enter Floor Name"),
                          content: TextField(
                            controller: floorNameController,
                            decoration: const InputDecoration(
                              labelText: "Floor Name",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(
                                context,
                              ).pop(floorNameController.text.trim()),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );

                      if (floorName != null && floorName.isNotEmpty) {
                        await _pickAndUploadFloorMap(floorName: floorName);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: floorMaps.entries.map((entry) {
                      final floorName = entry.key;
                      final base64Str = entry.value;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(floorName),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Color.fromARGB(255, 145, 42, 42),
                                ),
                                onPressed: () => _deleteFloorMap(floorName),
                              ),
                              IconButton(
                                icon: const Icon(Icons.open_in_new),
                                onPressed: () =>
                                    _viewFloorMap(base64Str, floorName),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
