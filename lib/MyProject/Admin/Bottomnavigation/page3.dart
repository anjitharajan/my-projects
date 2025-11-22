import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; 

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("hospitals");
  final List<Map<String, dynamic>> reviews = [];

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    final snapshot = await dbRef.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final List<Map<String, dynamic>> loadedReviews = [];

      data.forEach((hospitalId, hospitalData) {
        final hospital = Map<String, dynamic>.from(hospitalData);

        if (hospital.containsKey("feedback")) {
          final feedbackMap = Map<String, dynamic>.from(hospital["feedback"]);

          feedbackMap.forEach((fid, fdata) {
            final fb = Map<String, dynamic>.from(fdata);

            loadedReviews.add({
              "hospital": hospital["name"] ?? "Unknown Hospital",
              "hospitalId": hospitalId,
              "fid": fid,
              "message": fb["message"] ?? "",
              "date": fb["timestamp"] ?? "",
              "status": fb["attended"] == true ? "Attended" : "Pending",
            });
          });
        }
      });

      setState(() {
        reviews.clear();
        reviews.addAll(loadedReviews);
      });
    }
  }

  Future<void> markAsAttended(String hospitalId, String feedbackId) async {
    await dbRef
        .child("$hospitalId/feedback/$feedbackId")
        .update({"attended": true});
    fetchReviews(); // refresh the list
  }

  String formatDate(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return DateFormat('dd/MM/yyyy – hh:mm a').format(dt);
    } catch (_) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 8)],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hospital Feedback",
              style: GoogleFonts.merriweather(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(height: 2, width: double.infinity, color: Colors.white24),
            const SizedBox(height: 15),
            Expanded(
              child: reviews.isEmpty
                  ? Center(
                      child: Text(
                        "No feedback found.",
                        style: GoogleFonts.gloock(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final fb = reviews[index];

                        return Card(
                          color: Colors.white.withOpacity(0.95),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                                Text(
                                  fb["hospital"],
                                  style: GoogleFonts.ibarraRealNova(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),

                          
                                Text(
                                  fb["message"],
                                  style: GoogleFonts.ibarraRealNova(
                                    fontSize: 15,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),

                      
                                Text(
                                  "Date: ${formatDate(fb["date"])}",
                                  style: GoogleFonts.ibarraRealNova(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 12),

                            
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: fb["status"] == "Pending"
                                            ? Colors.orange
                                            : Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        fb["status"],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    if (fb["status"] == "Pending")
                                      ElevatedButton(
                                        onPressed: () => markAsAttended(
                                            fb["hospitalId"], fb["fid"]),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green),
                                        child: const Text("Mark as Attended"),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
