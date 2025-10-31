import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Bookingpage extends StatefulWidget {
  final Function(List<Map<String, String>>) onBooked; // callback to userhome

  Bookingpage({super.key, required this.onBooked});

  @override
  State<Bookingpage> createState() => _BookingpageState();
}

class _BookingpageState extends State<Bookingpage> {
  final List<Map<String, dynamic>> doctors = [
    {
      "name": "Dr. Maya Copper",
      "spec": "Psychologist - USA",
      "rating": 4.9,
      "img": "assets/doctor1.png",
    },
    {
      "name": "Dr. Dan AL Haj",
      "spec": "Psychologist - Germany",
      "rating": 4.8,
      "img": "assets/doctor2.png",
    },
    {
      "name": "Dr. Lara Mazola",
      "spec": "Psychologist - Italy",
      "rating": 4.7,
      "img": "assets/doctor3.png",
    },
  ];

  List<Map<String, String>> bookedAppointments = [];

  void _cancelAppointment(int index) {
    setState(() {
      bookedAppointments.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Appointment cancelled"),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _selectDateTime(
    BuildContext context,
    Map<String, dynamic> doctor,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    );

    if (pickedTime == null) return;

    final appointmentDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final appointment = {
      'doctorName': doctor['name'].toString(),
      'specialization': doctor['spec'].toString(),
      'date': "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}",
      'time': pickedTime.format(context),
      'dateTime': appointmentDateTime.toIso8601String(),
      'image': doctor['img'].toString(),
    };

    setState(() {
      bookedAppointments.add(appointment);
      bookedAppointments.sort((a, b) {
        return DateTime.parse(
          a['dateTime']!,
        ).compareTo(DateTime.parse(b['dateTime']!));
      });
    });

    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

    final doctorId = doctor['name'].toString().replaceAll(' ', '_');
    final newAppointmentRef = dbRef
        .child("Doctors/$doctorId/appointments")
        .push();
    const userId = "U123";
    const userName = "John Doe";
    const hospitalName = "Aster Medicity";

    await newAppointmentRef.set({
      "userId": userId,
      "userName": userName,
      "hospitalName": hospitalName,
      "date": appointment['date'],
      "time": appointment['time'],
      "status": "Pending",
    });

    final userAppointmentRef = dbRef.child("Users/$userId/appointments").push();

    await userAppointmentRef.set({
      "doctorName": appointment['doctorName'],
      "specialization": appointment['specialization'],
      "hospitalName": hospitalName,
      "date": appointment['date'],
      "time": appointment['time'],
      "status": "Pending",
    });

    final now = DateTime.now();
    final upcoming = bookedAppointments.firstWhere(
      (appt) => DateTime.parse(appt['dateTime']!).isAfter(now),
      orElse: () => {},
    );

    widget.onBooked(bookedAppointments);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appointment booked with ${doctor['name']}')),
    );
  }

  Widget _buildDoctorCard(
    String name,
    String spec,
    double rating,
    String imgPath,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.pink,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: AssetImage(imgPath), radius: 28),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(spec, style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 18),
              Text(rating.toString(), style: TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    String name,
    String desc,
    String time,
    Color color,
    int index,
  ) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(desc, style: TextStyle(color: Colors.grey, fontSize: 12)),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.black54),
                  SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _cancelAppointment(index),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text("Cancel"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(IconData icon, String title) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue, size: 26),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title:  Text("Book an Appointment"),
      //   centerTitle: true,
      // ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Upcoming Schedule",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: bookedAppointments.isNotEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: bookedAppointments.length,
                      itemBuilder: (context, index) {
                        final appt = bookedAppointments[index];
                        return _buildScheduleCard(
                          appt['doctorName']!,
                          appt['specialization']!,
                          "${appt['date']} • ${appt['time']}",
                          Colors.teal,
                          index,
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No appointments booked yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),

            SizedBox(height: 25),
            Text(
              "Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategory(Icons.favorite_border, "Heart"),
                _buildCategory(Icons.medical_services_outlined, "Doctor"),
                _buildCategory(Icons.note_alt_outlined, "Reports"),
                _buildCategory(Icons.person_outline, "Profile"),
              ],
            ),

            SizedBox(height: 25),
            Text(
              "Available Doctors",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            ...doctors.map((doc) {
              return GestureDetector(
                onTap: () async => await _selectDateTime(context, doc),
                child: _buildDoctorCard(
                  doc["name"]!,
                  doc["spec"]!,
                  doc["rating"]!,
                  doc["img"]!,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
