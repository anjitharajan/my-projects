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

  /// needed to fetch hospital services reports

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
      // 1️⃣ Fetch from user node
      final userSnap = await _db.child('users/${widget.userId}/reports').get();
      if (userSnap.exists) {
        for (var child in userSnap.children) {
          final report = Map<String, dynamic>.from(child.value as Map);
          tempReports.add(report);
        }
      }

      // 2️⃣ Fetch from hospital services node
      final hospitalSnap = await _db
          .child('hospitals/${widget.hospitalId}/services/reports')
          .get();
      if (hospitalSnap.exists) {
        for (var child in hospitalSnap.children) {
          final report = Map<String, dynamic>.from(child.value as Map);
          if (report['userId'] == widget.userId) {
            tempReports.add(report);
          }
        }
      }

      // 3️⃣ Remove duplicates based on reportId
      final ids = <String>{};
      tempReports = tempReports.where((r) {
        if (ids.contains(r['reportId'])) return false;
        ids.add(r['reportId']);
        return true;
      }).toList();

      // 4️⃣ Sort by date descending
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

  // Decode base64 in background isolate to prevent freeze
void _viewReportFile(String fileName, String fileData) async {
  if (fileData.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('No file attached')));
    return;
  }

  try {
    final bytes = base64Decode(fileData);

    final dir = await getTemporaryDirectory();
    final ext = fileName.contains('.') ? '' : '.txt'; // Ensure file has extension
    final file = File('${dir.path}/$fileName$ext');

    await file.writeAsBytes(bytes, flush: true);

    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: ${result.message}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error opening file: $e')));
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Medical Reports"),
        backgroundColor: Colors.amber,
        automaticallyImplyLeading: true,
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report['title'] ?? "No Title",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(report['description'] ?? "No Description"),
                        const SizedBox(height: 4),
                        Text(
                          "Date: ${report['date'] ?? "Unknown"}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                        Text(
                          "Hospital: ${widget.hospitalName}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                        if (report['fileData'] != null &&
                            report['fileData'] != "")
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _viewReportFile(
                                report['fileName'] ?? "File",
                                report['fileData'] ?? "",
                              ),
                              icon: const Icon(Icons.remove_red_eye),
                              label: const Text("View File"),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
