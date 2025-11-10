import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Bookingpage extends StatefulWidget {
  final Function(List<Map<String, String>>) onBooked;
  final String userId;
  final String userName;
    final String userEmail;

  Bookingpage({
    super.key,
    required this.onBooked,
    required this.userId,
    required this.userName,
        this.userEmail = "",
  });

  @override
  State<Bookingpage> createState() => _BookingpageState();
}

class _BookingpageState extends State<Bookingpage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> doctors = [];
  List<Map<String, String>> bookedAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _fetchUserAppointments();
  }

  Future<void> _fetchDoctors() async {
    setState(() => isLoading = true);

    try {
      final hospitalsSnapshot = await dbRef.child("hospitals").get();
      List<Map<String, dynamic>> loadedDoctors = [];

      if (hospitalsSnapshot.exists) {
        final hospitalsData = hospitalsSnapshot.value as Map<dynamic, dynamic>;

        hospitalsData.forEach((hospitalKey, hospitalValue) {
          final hospitalMap = Map<String, dynamic>.from(hospitalValue);
          final hospitalName = hospitalMap["name"] ?? "Unknown Hospital";
          final doctorsMap = hospitalMap["doctors"] as Map<dynamic, dynamic>?;

          if (doctorsMap != null) {
            doctorsMap.forEach((doctorKey, doctorValue) {
              final doctorMap = Map<String, dynamic>.from(doctorValue);

              loadedDoctors.add({
                "id": doctorKey,
                "name": doctorMap["name"] ?? "Unknown",
                "spec": doctorMap["specialization"] ?? "N/A",
                "rating": doctorMap["rating"] ?? 4.5,
                "img": "assets/doctor1.jpg",
                "hospital": hospitalName,
                "hospitalId": hospitalKey,
              });
            });
          }
        });
      } else {
        print("No hospitals or doctors found in Firebase");
      }

      setState(() {
        doctors = loadedDoctors;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching doctors: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchUserAppointments() async {
    try {
      final snapshot = await dbRef.child("users/${widget.userId}/appointments").get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, String>> loadedAppointments = data.values
            .map((e) => Map<String, String>.from(e))
            .toList();

        
        loadedAppointments.sort((a, b) =>
            DateTime.parse(a['dateTime']!).compareTo(DateTime.parse(b['dateTime']!)));

        setState(() {
          bookedAppointments = loadedAppointments;
        });
      }
    } catch (e) {
      print("Error fetching user appointments: $e");
    }
  }
  void _cancelAppointment(int index) async {
    final appt = bookedAppointments[index];
    try {
      // Remove from doctor node
      await dbRef
          .child(
            "hospitals/${appt['hospitalId']}/doctors/${appt['doctorId']}/appointments/${appt['appointmentId']}",
          )
          .remove();

      // Remove from user node
      await dbRef
          .child("users/${widget.userId}/appointments/${appt['appointmentId']}")
          .remove();

      setState(() {
        bookedAppointments.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Appointment cancelled"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print("Error cancelling appointment: $e");
    }
  }


  Future<void> _selectDateTime(
      BuildContext context, Map<String, dynamic> doctor) async {
    final doctorId = doctor['id']?.toString() ?? "";
    final hospitalId = doctor['hospitalId']?.toString() ?? "";

    if (doctorId.isEmpty || hospitalId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doctor or Hospital ID missing")),
      );
      return;
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

 
    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (pickedTime == null) return;

    final appointmentDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

  
    bool duplicate = bookedAppointments.any((appt) {
      final dt = appt['dateTime'];
      if (dt == null) return false;
      return DateTime.parse(dt).isAtSameMomentAs(appointmentDateTime) &&
          appt['doctorId'] == doctorId;
    });


    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You already have an appointment at this time.")),
      );
      return;
    }
    final appointmentId = dbRef.push().key!;


  
    final appointmentData = {
      "appointmentId": appointmentId,
      "userId": widget.userId,
      "userName": widget.userName,
      "userEmail": widget.userEmail,
      "doctorName": doctor['name']?.toString() ?? "",
      "doctorId": doctorId,
      "hospitalName": doctor['hospital']?.toString() ?? "",
      "hospitalId": hospitalId,
      "specialization": doctor['spec']?.toString() ?? "",
      "date": "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}",
      "time": pickedTime.format(context),
      "dateTime": appointmentDateTime.toIso8601String(),
      "status": "Booked",
      "createdAt": DateTime.now().toIso8601String(),
      "rating": doctor['rating']?.toString() ?? "4.5",
    };

    try {
  // Write to Firebase first
  await dbRef.child("hospitals/$hospitalId/doctors/$doctorId/appointments/$appointmentId")
      .set(appointmentData);
  await dbRef.child("users/${widget.userId}/appointments/$appointmentId")
      .set(appointmentData);
  await dbRef.child("hospitals/$hospitalId/connectedUsers/${widget.userId}")
      .set(true);

  // Then update local state
  setState(() {
    bookedAppointments.add(
      appointmentData.map((key, value) => MapEntry(key, value.toString()))
    );
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Appointment booked with ${doctor['name']}")),
  );
} catch (e) {
  // If Firebase write fails, local state is not updated
  print("Error booking appointment: $e");
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Failed to book appointment: $e")),
  );
}

  }
  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Color(0xFF042E51)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black26.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: AssetImage(doctor['img']), radius: 35),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  doctor['spec'] ?? "",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  doctor['hospital'] ?? "",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(
                      doctor['rating'].toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _selectDateTime(context, doctor),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF042E51),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Book"),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(String name, String desc, String time, int index) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Color(0xFF042E51)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _cancelAppointment(index),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text("Cancel"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upcoming Schedule",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 130,
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
                          index,
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        "No appointments booked yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Available Doctors",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF042E51)),
              )
            else if (doctors.isEmpty)
              const Center(
                child: Text(
                  "No doctors available",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  return _buildDoctorCard(doctors[index]);
                },
              ),
          ],
        ),
      ),
    );
  }
}
