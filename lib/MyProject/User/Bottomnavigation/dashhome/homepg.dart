import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virmedo/MyProject/User/Medicalrecord/medicalrecord.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/enablescreen/hospitalenable.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/hospitalscreen/hospitalsmainscreen.dart';

class Homepage extends StatefulWidget {
  final List<Map<String, String>> appointments;
  final String? userId;

  Homepage({super.key, this.appointments = const [], required this.userId});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final DatabaseReference _hospitalRef = FirebaseDatabase.instance.ref(
    "hospitals",
  );
  final DatabaseReference _userAppointmentsRef = FirebaseDatabase.instance.ref(
    "users",
  );
  List<Map<String, dynamic>> hospitals = [];
  List<Map<String, dynamic>> filteredHospitals = [];
  List<Map<String, String>> _appointments = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchHospitals();
    fetchUserAppointments();
    print("User ID in initState: ${widget.userId}");
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
        filteredHospitals = List.from(hospitals);
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  // ------------------------------------------------
  // SEARCH FILTER
  // ------------------------------------------------

  void _runSearch(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty, show all hospitals
      results = List.from(hospitals);
    } else {
      results = hospitals.where((hospital) {
        final name = hospital['name']?.toString().toLowerCase() ?? '';
        return name.contains(enteredKeyword.toLowerCase());
      }).toList();
    }

    setState(() {
      filteredHospitals = results;
    });
  }

  // ------------------------------------------------
  // FETCH USER APPOINTMENTS
  // ------------------------------------------------
  void fetchUserAppointments() {
    if (widget.userId == null) return;

    final ref = _userAppointmentsRef.child("${widget.userId}/appointments");

    ref.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);

        final loaded = data.entries.map((entry) {
          final appointmentId = entry.key;
          final values = Map<String, String>.from(entry.value);

          return {"appointmentId": appointmentId, ...values};
        }).toList();

        setState(() => _appointments = loaded);
      } else {
        setState(() => _appointments = []);
      }
    });
  }

  // ------------------------------------------------
  // GET UPCOMING APPOINTMENT
  // ------------------------------------------------
  Map<String, String>? getUpcomingAppointment() {
    if (_appointments.isEmpty)
      return null; // ✅ use _appointments not widget.appointments

    final now = DateTime.now();
    final upcoming = _appointments
        .where(
          (a) => DateTime.tryParse(a['dateTime'] ?? '')?.isAfter(now) ?? false,
        )
        .toList();

    if (upcoming.isEmpty) return null;

    upcoming.sort(
      (a, b) => DateTime.parse(
        a['dateTime']!,
      ).compareTo(DateTime.parse(b['dateTime']!)),
    );

    return upcoming.first;
  }

  @override
  Widget build(BuildContext context) {
    print("User ID in build: ${widget.userId}");
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
                controller: _searchController,
                onChanged: _runSearch,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 20, top: 1),
                    child: Icon(
                      Icons.search,
                      color: Color.fromARGB(255, 210, 218, 242),
                    ),
                  ),
                  hintText: "Search hospitals...",
                  hintStyle: GoogleFonts.germaniaOne(
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
                if (widget.userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User ID not available")),
                  );
                  return;
                }

                final upcoming = getUpcomingAppointment();
                if (upcoming == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No appointment found")),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MedicalRecordPage(
                      userId: widget.userId!,
                      // <--- added
                    ),
                  ),
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
                    style:  GoogleFonts.neuton(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "Upcoming Appointment",
                style:GoogleFonts.girassol(
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
                  style:GoogleFonts.girassol(
                  color: Color.fromARGB(255, 4, 46, 81),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 5),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredHospitals.isEmpty
                ? Center(
                    child: Text(
                      "No hospitals found",
                      style:  GoogleFonts.germaniaOne(
                        fontSize: 16, color: Colors.grey),
                    ),
                  )
                : CarouselSlider(
                   key: ValueKey(filteredHospitals.length),
                    options: CarouselOptions(
                      height: 260,
                      autoPlay: filteredHospitals.length > 1,

                      enlargeCenterPage: true,
                      viewportFraction: 0.75,
                    ),
                    items: filteredHospitals.map((hospital) {
                      final hospitalData = Map<String, dynamic>.from(hospital);

                      return Builder(
                        builder: (context) {
                          return GestureDetector(
                            onTap: () async {
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

                              //----------------------replacedone----------------//

                              if (widget.userId == null) return;

                              final userId = widget.userId!;
                              final hospitalId = hospitalData["id"].toString();

                              final ref = FirebaseDatabase.instance.ref(
                                "users/$userId/enabledHospitals/$hospitalId",
                              );

                              final snapshot = await ref.get();

                              if (snapshot.exists) {
                                // 🔥 Already enabled → DIRECTLY GO TO HOSPITAL PAGE
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HospitalPage(
                                      hospitalId: hospitalId,
                                      hospitalName: hospitalData["name"]
                                          .toString(),
                                      hospitalImage: hospitalData["image"]
                                          .toString(),
                                      aboutText:
                                          hospitalData["about"]?.toString() ??
                                          "Trusted healthcare partner for your wellness journey.",
                                      userId: userId,
                                    ),
                                  ),
                                );
                              } else {
                                // ❗ Not enabled → Go to the Enable Screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EnableScreen(
                                      hospitalId: hospitalId,
                                      hospitalName: hospitalData["name"]
                                          .toString(),
                                      hospitalImage: hospitalData["image"]
                                          .toString(),
                                      aboutText:
                                          hospitalData["about"]?.toString() ??
                                          "Trusted healthcare partner for your wellness journey.",
                                      userId: userId,
                                    ),
                                  ),
                                );
                              }
                            },

                            //-------------------original-----------------//

                            //   final enabledHospital = Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => EnableScreen(
                            //         hospitalId: hospitalData["id"].toString(),
                            //         hospitalName: hospitalData["name"]
                            //             .toString(),
                            //         hospitalImage: hospitalData["image"]
                            //             .toString(),
                            //         aboutText:
                            //             hospitalData["about"]?.toString() ??
                            //             "Trusted healthcare partner for your wellness journey.",
                            //         userId:
                            //             widget.userId!, // ✅ must be provided
                            //       ),
                            //     ),
                            //   );
                            // },

                            //------------------//
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
                                  style: GoogleFonts.neuton(
                                    color: Colors.white,
                                    fontSize: 20,
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(15),
        leading: CircleAvatar(radius: 28, backgroundImage: NetworkImage(image)),
        title: Text(
          doctor,
        style:GoogleFonts.neuton(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, size: 16, color: Colors.white70),
                SizedBox(width: 6),
                Text(
                  spec,
                  style: GoogleFonts.germaniaOne(
                    color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                SizedBox(width: 6),
                Text(
                  date,
                  style:  GoogleFonts.germaniaOne(
                    color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.white70),
                SizedBox(width: 6),
                Text(
                  time,
                  style: GoogleFonts.germaniaOne(
                    color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAppointmentCard() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "No upcoming appointments",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "You can book your appointment.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
