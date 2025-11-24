import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virmedo/MyProject/Doctor/appoint_sec_page/apoointsecpage.dart';
import 'package:virmedo/MyProject/signup/login/loginpage.dart';

class DoctorAppointmentsPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String hospitalId;

  const DoctorAppointmentsPage({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.hospitalId,
  });

  @override
  State<DoctorAppointmentsPage> createState() => _DoctorAppointmentsPageState();
}

class _DoctorAppointmentsPageState extends State<DoctorAppointmentsPage> {
  final dbRef = FirebaseDatabase.instance.ref();
  late DatabaseReference appointmentsRef;

  @override
  void initState() {
    super.initState();
    print("Doctor Screen → doctorId = ${widget.doctorId}");
    print("Doctor Screen → hospitalId = ${widget.hospitalId}");
    print(
      "Doctor Screen → Path = hospitals/${widget.hospitalId}/doctors/${widget.doctorId}/appointments",
    );

    print(
      "DoctorAppointmentsPage: doctorId=${widget.doctorId}, hospitalId=${widget.hospitalId}",
    );
    appointmentsRef = dbRef.child(
      "hospitals/${widget.hospitalId}/doctors/${widget.doctorId}/appointments",
    );
    appointmentsRef.get().then((snapshot) {
      print("Initial snapshot value: ${snapshot.value}");
    });
  }

  // // ------------------- Add Prescription -------------------//
  // Future<void> _addPrescription({
  //   required String appointmentId,
  //   required String userId,
  //   required String userName,
  //   required String hospitalName,
  // }) async {
  //   final controller = TextEditingController();
  //   final root = FirebaseDatabase.instance.ref();

  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         child: Container(
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight,
  //             ),
  //             borderRadius: BorderRadius.circular(20),
  //           ),

  //           child: Padding(
  //             padding: const EdgeInsets.all(20),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(
  //                   "Add Prescription",
  //                   style: GoogleFonts.gloock(
  //                     color: Colors.white,
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),

  //                 SizedBox(height: 15),
  //                 TextField(
  //                   controller: controller,
  //                   maxLines: 4,
  //                   style: GoogleFonts.boogaloo(color: Colors.white),
  //                   decoration: InputDecoration(
  //                     hintText: "Enter prescription details...",
  //                     hintStyle: GoogleFonts.oregano(
  //                       color: Colors.white70,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 17,
  //                     ),
  //                     filled: true,
  //                     fillColor: Colors.white.withOpacity(0.1),
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                       borderSide: BorderSide.none,
  //                     ),
  //                   ),
  //                 ),

  //                 const SizedBox(height: 20),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     TextButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       child: Text(
  //                         "Cancel",
  //                         style: GoogleFonts.germaniaOne(color: Colors.white),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 10),
  //                     ElevatedButton(
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.white,
  //                         foregroundColor: Color(0xFF2575FC),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                       ),
  //                       onPressed: () async {
  //                         final text = controller.text.trim();
  //                         if (text.isEmpty) return;

  //                         final prescriptionData = {
  //                           "appointmentId": appointmentId,
  //                           "userId": userId,
  //                           "userName": userName,
  //                           "doctorId": widget.doctorId,
  //                           "doctorName": widget.doctorName,
  //                           "hospitalId": widget.hospitalId,
  //                           "hospitalName": hospitalName,
  //                           "date": DateTime.now().toIso8601String(),
  //                           "prescription": text,
  //                         };

  //                         // ------------------- adding prescription inside the hospital/doctor/appointment/medical record -------------------\\
  //                         await root
  //                             .child(
  //                               "hospitals/${widget.hospitalId}/doctors/${widget.doctorId}/appointments/$appointmentId/medicalRecord",
  //                             )
  //                             .set(prescriptionData);

  //                         // ------------------- store inside the user/medical record -------------------\\
  //                         await root
  //                             .child("users/$userId/medicalRecord")
  //                             .push()
  //                             .set(prescriptionData);

  //                         Navigator.pop(context);
  //                       },
  //                       child: Text(
  //                         "Save",
  //                         style: GoogleFonts.germaniaOne(
  //                           color: Color.fromARGB(255, 4, 46, 81),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // // ------------------- Add Diet Plan -------------------\\
  // Future<void> _addDietPlan({
  //   required String appointmentId,
  //   required String userId,
  //   required String userName,
  //   required String hospitalName,
  // }) async {
  //   final controller = TextEditingController();
  //   final root = FirebaseDatabase.instance.ref();

  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         child: Container(
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight,
  //             ),
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           child: Padding(
  //             padding: const EdgeInsets.all(20),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(
  //                   "Add Diet Plan",
  //                   style: GoogleFonts.gloock(
  //                     color: Colors.white,
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),

  //                 const SizedBox(height: 15),
  //                 TextField(
  //                   controller: controller,
  //                   maxLines: 4,
  //                   style: GoogleFonts.boogaloo(color: Colors.white),
  //                   decoration: InputDecoration(
  //                     hintText: "Enter diet plan details...",
  //                     hintStyle: GoogleFonts.oregano(
  //                       color: Colors.white70,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 17,
  //                     ),
  //                     filled: true,
  //                     fillColor: Colors.white.withOpacity(0.1),
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                       borderSide: BorderSide.none,
  //                     ),
  //                   ),
  //                 ),

  //                 const SizedBox(height: 20),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     TextButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       child: Text(
  //                         "Cancel",
  //                         style: GoogleFonts.germaniaOne(color: Colors.white),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 10),
  //                     ElevatedButton(
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.white,
  //                         foregroundColor: Color(0xFF2575FC),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                       ),
  //                       onPressed: () async {
  //                         final text = controller.text.trim();
  //                         if (text.isEmpty) return;
  //                         final dietData = {
  //                           "appointmentId": appointmentId,
  //                           "userId": userId,
  //                           "userName": userName,
  //                           "doctorId": widget.doctorId,
  //                           "doctorName": widget.doctorName,
  //                           "hospitalId": widget.hospitalId,
  //                           "hospitalName": hospitalName,
  //                           "date": DateTime.now().toIso8601String(),
  //                           "dietPlan": text,
  //                         };

  //                         // ------------------- adding diet inside the hospital/doctor/appoinment/diet -------------------\\
  //                         await root
  //                             .child(
  //                               "hospitals/${widget.hospitalId}/doctors/${widget.doctorId}/appointments/$appointmentId/diet",
  //                             )
  //                             .set(dietData);
  //                         // ------------------- Add Diet inside the user/diet -------------------\\
  //                         await root
  //                             .child("users/$userId/diet")
  //                             .push()
  //                             .set(dietData);

  //                         Navigator.pop(context);
  //                       },
  //                       child: Text(
  //                         "Save",
  //                         style: GoogleFonts.germaniaOne(
  //                           color: Color.fromARGB(255, 4, 46, 81),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // ------------------- Cancel Appointment -------------------\\
  Future<void> _cancelAppointment(String appointmentId) async {
    await dbRef
        .child(
          "hospitals/${widget.hospitalId}/doctors/${widget.doctorId}/appointments/$appointmentId",
        )
        .remove();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Appointment cancelled"),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ------------------- ui design -------------------\\
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        height: 60, // custom height
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
              (route) => false,
            );
          },
          // Gradient background
          label: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.black, Colors.blue]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          " Appointments for  Dr. ${widget.doctorName}",
          style: GoogleFonts.merriweather(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

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

      body: StreamBuilder<DatabaseEvent>(
        stream: appointmentsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No appointments yet."));
          }

          final snapshotValue = snapshot.data!.snapshot.value;
          print(
            "Firebase raw snapshot: $snapshotValue (${snapshotValue.runtimeType})",
          );

          List<MapEntry<dynamic, dynamic>> apptList;

          if (snapshotValue is Map) {
            apptList = snapshotValue.entries.toList();
          } else if (snapshotValue is List) {
            apptList = snapshotValue
                .asMap()
                .entries
                .where((e) => e.value != null)
                .map((e) => MapEntry(e.key, e.value))
                .toList();
          } else {
            return const Center(child: Text("No appointments available."));
          }

          if (apptList.isEmpty) {
            return const Center(child: Text("No appointments yet."));
          }

          //--------------- Sort appointments by date and Time----------------\\
          apptList.sort((a, b) {
            final aDate =
                DateTime.tryParse(a.value['dateTime']?.toString() ?? '') ??
                DateTime.now();
            final bDate =
                DateTime.tryParse(b.value['dateTime']?.toString() ?? '') ??
                DateTime.now();
            return aDate.compareTo(bDate);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: apptList.length,
            itemBuilder: (context, index) {
              final appt = Map<String, dynamic>.from(apptList[index].value);
              final appointmentId = apptList[index].key;
              final userEmail =
                  appt["userEmail"] ??
                  appt["email"] ??
                  appt["user_email"] ??
                  appt["mail"] ??
                  "No Email";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorSecondPage(
                          appointmentId: appointmentId.toString(),
                          userId: appt["userId"],
                          userName: appt["userName"],
                          doctorId: widget.doctorId,
                          doctorName: widget.doctorName,
                          hospitalId: widget.hospitalId,
                          hospitalName:
                              appt["hospitalName"] ?? "Unknown Hospital",
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 36,
                      ),
                      title: Text(
                        appt["userName"] ?? "Unknown User",
                        style: GoogleFonts.merriweather(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${appt["date"] ?? ""} • ${appt["time"] ?? ""}",
                            style: GoogleFonts.germaniaOne(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (appt["status"] != null)
                            Text(
                              "Status: ${appt["status"]}",
                              style: GoogleFonts.gloock(
                                color: appt["status"] == "Booked"
                                    ? const Color.fromARGB(255, 157, 244, 160)
                                    : const Color.fromARGB(255, 241, 161, 156),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          Text(
                            "Email: $userEmail",
                            style: GoogleFonts.gloock(color: Colors.white),
                          ),
                        ],
                      ),

                      trailing: IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          size: 29,
                          color: Color.fromARGB(255, 235, 48, 35),
                        ),
                        onPressed: () => _cancelAppointment(appointmentId),
                      ),
                      // Row(
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     PopupMenuButton<String>(
                      //       icon: Icon(Icons.more_vert, color: Colors.white),
                      //       color: Colors.transparent,
                      //       elevation: 0,
                      //       onSelected: (value) {
                      //         if (value == 'prescription') {
                      //           _addPrescription(
                      //             appointmentId: appointmentId,
                      //             userId: appt["userId"],
                      //             userName: appt["userName"],
                      //             hospitalName:
                      //                 appt["hospitalName"] ?? widget.hospitalId,
                      //           );
                      //         } else if (value == 'diet') {
                      //           _addDietPlan(
                      //             appointmentId: appointmentId,
                      //             userId: appt["userId"],
                      //             userName: appt["userName"],
                      //             hospitalName:
                      //                 appt["hospitalName"] ?? widget.hospitalId,
                      //           );
                      //         }
                      //       },
                      //       itemBuilder: (context) => [
                      //         PopupMenuItem(
                      //           value: 'prescription',
                      //           child: Ink(
                      //             decoration: BoxDecoration(
                      //               gradient: LinearGradient(
                      //                 colors: [
                      //                   Color(0xFF6A11CB),
                      //                   Color(0xFF2575FC),
                      //                 ],
                      //                 begin: Alignment.topLeft,
                      //                 end: Alignment.bottomRight,
                      //               ),
                      //               borderRadius: BorderRadius.circular(10),
                      //             ),
                      //             child: Container(
                      //               padding: EdgeInsets.all(10),
                      //               child: Text(
                      //                 "Add Prescription",
                      //                 style: GoogleFonts.dmSerifDisplay(
                      //                   color: Colors.white,
                      //                   fontWeight: FontWeight.w600,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //         PopupMenuItem(
                      //           value: 'diet',
                      //           child: Ink(
                      //             decoration: BoxDecoration(
                      //               gradient: LinearGradient(
                      //                 colors: [
                      //                   Color(0xFF00B09B),
                      //                   Color(0xFF96C93D),
                      //                 ],
                      //                 begin: Alignment.topLeft,
                      //                 end: Alignment.bottomRight,
                      //               ),
                      //               borderRadius: BorderRadius.circular(10),
                      //             ),
                      //             child: Container(
                      //               padding: EdgeInsets.all(10),
                      //               child: Text(
                      //                 "Add Diet Plan",
                      //                 style: GoogleFonts.dmSerifDisplay(
                      //                   color: Colors.white,
                      //                   fontWeight: FontWeight.w600,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //     IconButton(
                      //       icon: const Icon(
                      //         Icons.cancel,
                      //         size: 29,
                      //         color: Color.fromARGB(255, 235, 48, 35),
                      //       ),
                      //       onPressed: () => _cancelAppointment(appointmentId),
                      //     ),
                      //   ],
                      // ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
