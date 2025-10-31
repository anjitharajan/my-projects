import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Page3 extends StatefulWidget {
   Page3({super.key});

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
        if (hospital.containsKey("reviews")) {
          final reviewList = Map<String, dynamic>.from(hospital["reviews"]);
          reviewList.forEach((reviewId, reviewData) {
            final review = Map<String, dynamic>.from(reviewData);
            loadedReviews.add({
              "hospital": hospital["name"],
              "rating": review["rating"],
              "review": review["review"],
              "reviewer": review["reviewer"],
            });
          });
        }
      });

      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          gradient:  LinearGradient(
            colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black, blurRadius: 8)],
        ),
        padding:  EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              "Hospital Reviews",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            Container(height: 2, width: double.infinity, color: Colors.white24),

             SizedBox(height: 20),
            Expanded(
              child: reviews.isEmpty
                  ?  Center(
                      child: Text(
                        "No reviews found.",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Card(
                          color: Colors.white.withOpacity(0.9),
                          margin:  EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade700,
                              child: Text(
                                review['rating'].toString(),
                                style:  TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              review['hospital'],
                              style:  TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              '"${review['review']}"\n— ${review['reviewer']}',
                              style:  TextStyle(height: 1.4),
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
