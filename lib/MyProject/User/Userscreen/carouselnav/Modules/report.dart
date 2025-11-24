import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class UserReportScreen extends StatefulWidget {
  final String userId;
  final String hospitalId;
  final String hospitalName;

  const UserReportScreen({
    Key? key,
    required this.userId,
    required this.hospitalId,
    required this.hospitalName,
  }) : super(key: key);

  @override
  State<UserReportScreen> createState() => _UserReportScreenState();
}

class _UserReportScreenState extends State<UserReportScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

Future<void> _fetchReports() async {
  setState(() => _isLoading = true);
  List<Map<String, dynamic>> tempReports = [];

  try {
    //---------------------fetching only from user node---------------\\
    final userSnap = await _db.child('users/${widget.userId}/reports').get();
    if (userSnap.exists) {
      for (var child in userSnap.children) {
        final report = Map<String, dynamic>.from(child.value as Map);
        tempReports.add(report);
      }
    }

    //-----------------sort by date descending--------------\\
    tempReports.sort((a, b) {
      try {
        final dateA = DateFormat('dd-MM-yyyy hh:mm a').parse(a['date']);
        final dateB = DateFormat('dd-MM-yyyy hh:mm a').parse(b['date']);
        return dateB.compareTo(dateA);
      } catch (_) {
        return 0;
      }
    });

    setState(() => _reports = tempReports);
  } catch (e) {
    print("Error fetching reports: $e");
    setState(() => _reports = []);
  }

  setState(() => _isLoading = false);
}


Future<void> _viewReportFile(String fileName, String fileData) async {
  if (fileData.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No file attached')),
    );
    return;
  }

  try {
    // 1️⃣ Decode base64 safely
    String cleanedData = fileData.replaceAll(RegExp(r'\s'), '');
    cleanedData = cleanedData.replaceAll('-', '+').replaceAll('_', '/');
    while (cleanedData.length % 4 != 0) cleanedData += '=';

    Uint8List bytes = base64Decode(cleanedData);

    if (bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File data is empty')),
      );
      return;
    }

    // 2️⃣ Sanitize file name
    String safeFileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

    // 3️⃣ Add file extension if missing
    if (!safeFileName.contains('.')) {
      if (bytes.length > 4) {
        if (bytes[0] == 0x25 && bytes[1] == 0x50) safeFileName += '.pdf'; // PDF
        else if (bytes[0] == 0x89 && bytes[1] == 0x50) safeFileName += '.png'; // PNG
        else if (bytes[0] == 0xFF && bytes[1] == 0xD8) safeFileName += '.jpg'; // JPG
        else safeFileName += '.txt'; // fallback
      } else {
        safeFileName += '.txt';
      }
    }

    // 4️⃣ Get temporary directory
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$safeFileName');

    // 5️⃣ Write bytes to file
    await file.writeAsBytes(bytes, flush: true);

    // 6️⃣ Verify file exists
    if (!await file.exists() || (await file.length()) == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File does not exist or is empty')),
      );
      return;
    }

    // 7️⃣ Open file using OpenFile plugin
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: ${result.message}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error opening file: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Medical Reports"),
        backgroundColor: Colors.amber,
       // automaticallyImplyLeading: true,
      ),
        body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? const Center(child: Text("No reports available"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report['title'] ?? "No Title",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(report['description'] ?? "No Description"),
                              const SizedBox(height: 4),
                              Text(
                                "Date: ${report['date'] ?? "Unknown"}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                "Hospital: ${widget.hospitalName}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              if (report['fileData'] != null &&
                                  report['fileData'] != "")
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => _viewReportFile(
                                        report['fileName'] ?? "File",
                                        report['fileData'] ?? ""),
                                    icon: const Icon(Icons.remove_red_eye),
                                    label: const Text("View File"),
                                  ),
                                ),
                            ]),
                      ),
                    );
                  },
                ),
    );
  }
}