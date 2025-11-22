import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class ReportScreen extends StatefulWidget {
  final String hospitalId;
  final String hospitalName;
  const ReportScreen({
    Key? key,
    required this.hospitalId,
    required this.hospitalName,
  }) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> enabledUsers = [];
  bool _isUsersLoading = true;

  File? _selectedFile;
  String? _fileName;
  String? _base64File;
  String? _selectedUserId;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEnabledUsers();
  }

  // ---------------- LOAD ENABLED USERS ----------------\\
  Future<void> _loadEnabledUsers() async {
    setState(() => _isUsersLoading = true);
    enabledUsers.clear();

    try {
      final snap = await _db
          .child("hospitals/${widget.hospitalId}/connectedUsers")
          .get();

      if (!snap.exists) return;

      for (var child in snap.children) {
        String userId = child.key!;
        dynamic value = child.value;

        // Case 1: value is true → user is connected
        bool isEnabled = false;
        if (value is bool) {
          isEnabled = value;
        }
        // Case 2: value is a map → assume connected
        else if (value is Map) {
          isEnabled = true;
        }

        if (!isEnabled) continue;

        // Fetch user info from 'users' node
        final userSnap = await _db.child("users/$userId").get();
        String name =
            userSnap.child("name").value?.toString() ??
            (value is Map && value["name"] != null
                ? value["name"]
                : "Unnamed User");

        enabledUsers.add({"userId": userId, "name": name});
      }
    } catch (e) {
      print("Error loading enabled users: $e");
    } finally {
      setState(() => _isUsersLoading = false);
    }
  }

  // Future<void> _loadEnabledUsers() async {
  //   setState(() => _isUsersLoading = true);

  //   try {
  //     final snap = await _db
  //         .child("hospitals/${widget.hospitalId}/connectedUsers")
  //         .get();
  //     print("ConnectedUsers snapshot exists: ${snap.exists}");
  //     print("ConnectedUsers value: ${snap.value}");

  //     enabledUsers.clear();

  //     if (snap.exists && snap.value != null) {
  //       for (var child in snap.children) {
  //         String userId = child.key!;
  //         final userData = await _db.child("users/$userId").get();

  //         if (!userData.exists) continue; // Skip if user node missing

  //         // Fetch user name
  //         String name =
  //             userData.child("name").value?.toString() ?? "Unnamed User";

  //         // Fetch isEnabled safely (if missing, assume true)
  //         final isEnabledValue = userData.child("isEnabled").value;
  //         bool isEnabled = true; // default true
  //         if (isEnabledValue != null) {
  //           if (isEnabledValue is bool) {
  //             isEnabled = isEnabledValue;
  //           } else if (isEnabledValue is String) {
  //             isEnabled = isEnabledValue.toLowerCase() == "true";
  //           } else if (isEnabledValue is int) {
  //             isEnabled = isEnabledValue != 0;
  //           }
  //         }

  //         if (isEnabled) {
  //           enabledUsers.add({"userId": userId, "name": name});
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print("Error loading users: $e");
  //     enabledUsers = [];
  //   } finally {
  //     setState(() => _isUsersLoading = false);
  //   }
  // }

  // ---------------- PICK FILE ----------------\\
  // ---------------- PICK FILE ----------------\\
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      final fileBytes = result.files.single.bytes;
      final fileName = result.files.single.name;

      if (fileBytes != null) {
        setState(() {
          _fileName = fileName;
          _base64File = base64Encode(fileBytes);
        });
      } else if (result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedFile = file;
          _fileName = p.basename(file.path);
          _base64File = base64Encode(bytes);
        });
      }

      // After picking file, prompt to select user
      _selectUserDialog();
    }
  }

  // ---------------- SELECT USER DIALOG ----------------\\
  Future<void> _selectUserDialog() async {
    if (_isUsersLoading) {
      // Wait until users are loaded
      await _loadEnabledUsers();
    }

    if (enabledUsers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No enabled users found')));
      return;
    }

    String? userId = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select User for Report"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: enabledUsers.length,
            itemBuilder: (context, index) {
              final u = enabledUsers[index];
              return ListTile(
                title: Text(u["name"]),
                onTap: () => Navigator.pop(context, u["userId"]),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );

    if (userId != null) {
      setState(() {
        _selectedUserId = userId;
      });
    }
  }

  // ---------------- SAVE REPORT ----------------\\
  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_base64File == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please attach a file')));
      return;
    }
    if (_selectedUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a user')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String reportId = const Uuid().v4();
      final reportData = {
        'reportId': reportId,
        'hospitalId': widget.hospitalId,
        'hospitalName': widget.hospitalName, // add this
        'userId': _selectedUserId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'fileName': _fileName,
        'fileData': _base64File,
        'date': DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now()),
      };

      // Save under user node
      await _db
          .child('users')
          .child(_selectedUserId!)
          .child('reports')
          .child(reportId)
          .set(reportData);

      // Save under hospital services node (like MapServicePage)
      await _db
          .child('hospitals')
          .child(widget.hospitalId)
          .child('services')
          .child('reports')
          .child(reportId)
          .set(reportData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report added successfully!')),
      );

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedFile = null;
        _fileName = null;
        _base64File = null;
        _selectedUserId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding report: $e')));
    }

    setState(() => _isLoading = false);
  }

  // ---------------- BUILD UI ----------------\\
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Reports",
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,

        backgroundColor: Colors.transparent,
        elevation: 0,

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- SELECT USER BUTTON ----------------\\
              if (_fileName != null)
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selectUserDialog,
                    icon: const Icon(Icons.person),
                    label: Text(
                      _selectedUserId == null ? "Select User" : "User Selected",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF043051),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Container(
                 padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 4, 46, 81),
                Colors.blue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
              ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "Report Title",
                      border: InputBorder.none,
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter title" : null,
                     ),
              ),
            ),
          ),
        ),

              const SizedBox(height: 20),
              Container(
                      decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 4, 46, 81),
                Colors.blue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
              ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: InputBorder.none,
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter description" : null,
                         ),
              ),
            ),
          ),
        ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    _fileName == null ? "Attach File" : "Attached: $_fileName",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF043051),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveReport,
                        icon: const Icon(Icons.upload),
                        label: const Text("Save Report"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF043051),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                        const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
