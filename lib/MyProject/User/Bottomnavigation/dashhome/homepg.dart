import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:virmedo/MyProject/User/Bottomnavigation/account/medicalrcd.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/enablescreen/hospitalenable.dart';

class Homepage extends StatefulWidget {
  final List<Map<String, String>> appointments;
  final String? userId;

  Homepage({super.key,    this.appointments = const [], required this.userId});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
 final DatabaseReference _hospitalRef = FirebaseDatabase.instance.ref("hospitals");
  final DatabaseReference _userAppointmentsRef = FirebaseDatabase.instance.ref("users");
  List<Map<String, dynamic>> hospitals = [];
  List<Map<String, String>> _appointments = [];
  bool isLoading = true;
  @override
 void initState() {
    super.initState();
    fetchHospitals();
    fetchUserAppointments();
  }

  void fetchHospitals() {
    _hospitalRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        hospitals.clear();
        data.forEach((key, value) {
          hospitals.add({
            "id": key, // Auto-generated Firebase ID
            "name": value["name"] ?? "Unknown Hospital",
            "image": value["image"] ?? "https://via.placeholder.com/150",
            "about": value["about"] ?? "Trusted healthcare partner.",
          });
        });
      }
      setState(() {
        isLoading = false;
      });
    });
  }

    void fetchUserAppointments() {
    if (widget.userId == null) return;
    final ref = _userAppointmentsRef.child("${widget.userId}/appointments");

    ref.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final loaded = data.values.map((e) => Map<String, String>.from(e)).toList();
        setState(() => _appointments = loaded);
      } else {
        setState(() => _appointments = []);
      }
    });
  }
 Map<String, String>? getUpcomingAppointment() {
  if (_appointments.isEmpty) return null; // ✅ use _appointments not widget.appointments

  final now = DateTime.now();
  final upcoming = _appointments
      .where((a) => DateTime.tryParse(a['dateTime'] ?? '')?.isAfter(now) ?? false)
      .toList();

  if (upcoming.isEmpty) return null;

  upcoming.sort(
    (a, b) => DateTime.parse(a['dateTime']!).compareTo(DateTime.parse(b['dateTime']!)),
  );

  return upcoming.first;
}


  @override
  Widget build(BuildContext context) {
    final upcomingAppointment = getUpcomingAppointment(); 
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Color.fromARGB(255, 4, 46, 81)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 20, top: 1),
                    child: Icon(
                      Icons.search,
                      color: Color.fromARGB(255, 210, 218, 242),
                    ),
                  ),
                  hintText: "Search",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 210, 218, 242),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            SizedBox(height: 25),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => medicalrcdscreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "My Medical Records",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "Upcoming Appointment",
                style: TextStyle(
                  color: Color.fromARGB(255, 4, 46, 81),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 5),
 upcomingAppointment != null
    ? _buildAppointmentCard(
        upcomingAppointment['doctorName'] ?? "Doctor",
        upcomingAppointment['specialization'] ?? "General",
        upcomingAppointment['date'] ?? "Unknown Date",
        upcomingAppointment['time'] ?? "Unknown Time",
        upcomingAppointment['doctorImage'] ??
            "https://via.placeholder.com/150",
      )
    : _buildNoAppointmentCard(),

            SizedBox(height: 30),
            Center(
              child: Text(
                "Nearby Hospitals",
                style: TextStyle(
                  color: Color.fromARGB(255, 4, 46, 81),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 5),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : hospitals.isEmpty
                ? const Center(child: Text("No hospitals available"))
                : CarouselSlider(
                    options: CarouselOptions(
                      height: 260,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.75,
                    ),
                    items: hospitals.map((hospital) {
                      final hospitalData = Map<String, dynamic>.from(hospital);

                      return Builder(
                        builder: (context) {
                          return GestureDetector(
                            onTap: () {
                              if (hospitalData["id"] == null ||
                                  hospitalData["name"] == null ||
                                  hospitalData["image"] == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Invalid hospital data"),
                                  ),
                                );
                                return;
                              }

                              final enabledHospital = Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EnableScreen(
                                    hospitalId: hospitalData["id"].toString(),
                                    hospitalName: hospitalData["name"]
                                        .toString(),
                                    hospitalImage: hospitalData["image"]
                                        .toString(),
                                    aboutText:
                                        hospitalData["about"]?.toString() ??
                                        "Trusted healthcare partner for your wellness journey.",
                                    userId:
                                        widget.userId!, // ✅ must be provided
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Color.fromARGB(255, 4, 46, 81),
                                  width: 2,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    hospitalData["image"] ?? "",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.5),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                                alignment: Alignment.bottomLeft,
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  hospitalData["name"]!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    String doctor,
    String spec,
    String date,
    String time,
    String image,
  ) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(image)),
        title: Text(doctor),
        subtitle: Text("$spec\n$date • $time"),
      ),
    );
  }

  Widget _buildNoAppointmentCard() {
    return Card(
      elevation: 3,
      child: ListTile(
        title: Text("No upcoming appointments"),
        subtitle: Text("You can book your Appointment."),
      ),
    );
  }
}
