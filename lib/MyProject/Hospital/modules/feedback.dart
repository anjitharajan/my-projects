import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HospitalFeedbackPage extends StatefulWidget {
  final String hospitalId;

  const HospitalFeedbackPage({
    super.key,
    required this.hospitalId,
  });

  @override
  State<HospitalFeedbackPage> createState() => _HospitalFeedbackPageState();
}

class _HospitalFeedbackPageState extends State<HospitalFeedbackPage> {
  final TextEditingController feedbackController = TextEditingController();
 late DatabaseReference feedbackRef;

  @override
  void initState() {
    super.initState();
    feedbackRef = FirebaseDatabase.instance
        .ref("hospitals/${widget.hospitalId}/feedback");
  }


  //-------------- feedback submit -----------------\\
  void submitFeedback() {
    if (feedbackController.text.trim().isEmpty) return;

    final id = feedbackRef.push().key;

    feedbackRef.child(id!).set({
      "message": feedbackController.text.trim(),
      "timestamp": DateTime.now().toString(),
      "attended": false,
    }).then((_) {
      feedbackController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback submitted")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dbQuery = FirebaseDatabase.instance
        .ref("feedback")
        .orderByChild("hospitalId")
        .equalTo(widget.hospitalId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hospital Feedback"),
        backgroundColor: Colors.blue,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            //---------------- add feedback ----------------\\
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.blue,
                    Color.fromARGB(255, 4, 46, 81),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                    color: Colors.black26,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add Feedback",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Enter your feedback...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                      ),
                      child: const Text("Submit"),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            //---------------- feedback list down ----------------\\
            Expanded(
              child: StreamBuilder(
                stream: dbQuery.onValue,
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.data?.snapshot.value == null) {
                    return const Center(
                      child: Text("No feedback yet"),
                    );
                  }

                  final data = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map,
                  );

                  final items = data.entries.toList();

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final entry = items[index];
                      final feedback =
                          Map<String, dynamic>.from(entry.value);

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          title: Text(
                            feedback["message"],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            feedback["timestamp"],
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: feedback["attended"] == true
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              feedback["attended"] == true
                                  ? "Attended"
                                  : "Pending",
                              style: TextStyle(
                                color: feedback["attended"] == true
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
