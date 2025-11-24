import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:virmedo/MyProject/Hospital/bottomnavigation/haccountpage.dart';
import 'package:virmedo/MyProject/Hospital/bottomnavigation/hpatientpage.dart';
import 'package:virmedo/MyProject/Hospital/modules/emergency.dart';
import 'package:virmedo/MyProject/Hospital/modules/feedback.dart';
import 'package:virmedo/MyProject/Hospital/modules/map.dart';
import 'package:virmedo/MyProject/Hospital/modules/report.dart';
import 'package:virmedo/MyProject/Hospital/modules/request_page.dart';
import 'package:virmedo/MyProject/Hospital/modules/room_service_page.dart';

class HospitalMainPage extends StatefulWidget {
  final String hospitalId;
  final String hospitalName;
  final String hospitalImage;
  final String aboutText;
  final String userId;
    final String contact;
  final String hospitalCode;

  HospitalMainPage({
    super.key,
    required this.hospitalId,
    required this.hospitalName,
    required this.hospitalImage,
    required this.aboutText,
    required this.userId,
    this.contact = '',
        this.hospitalCode = '',
  });

  @override
  State<HospitalMainPage> createState() => _HospitalMainPageState();
}

class _HospitalMainPageState extends State<HospitalMainPage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  int _selectedIndex = 0;
  List<String> connectedUsers = [];

  @override
  void initState() {
    super.initState();
    listenToConnectedUsers();
  }
  //-----------------------connected user-------------\\
  void listenToConnectedUsers() {
    dbRef.child("hospitals/${widget.hospitalId}/connectedUsers").onValue.listen(
      (event) {
        final data = event.snapshot.value;
        if (data != null && data is Map) {
          setState(() {
            connectedUsers = data.keys.cast<String>().toList();
          });
        } else {
          setState(() {
            connectedUsers = [];
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;

    final List<Widget> pages = [
      _dashboardScreen(),
      _doctorManagementScreen(),
      PatientPage(hospitalId: widget.hospitalId),

      AccountPage(hospitalId: widget.hospitalId),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: isDesktop
          ? Row(
              children: [
                _buildSidebar(),
                Expanded(child: pages[_selectedIndex]),
              ],
            )
          : pages[_selectedIndex],
      bottomNavigationBar: isDesktop ? null : _buildBottomNavigationBar(),
    );
  }

//--------------------desktop view ---------------------\\
  Widget _buildSidebar() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 0)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Hospital Panel",
              style: GoogleFonts.dmSerifDisplay(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(color: Colors.white24, thickness: 3),
          _sidebarItem(Icons.dashboard, "Dashboard", 0),
          _sidebarItem(Icons.medical_information, "Doctors", 1),
          _sidebarItem(Icons.people, "Patients", 2),
          _sidebarItem(Icons.account_circle, "Account", 3),
          Spacer(),
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "© 2025 VIRMEDO",
              style: GoogleFonts.germaniaOne(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, int index) {
    final bool selected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(title, style: GoogleFonts.gloock(color: Colors.white)),
        ),
      ),
    );
  }
  //--------------------mobile view ------------------------\\
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 4, 46, 81), Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,

          selectedLabelStyle: GoogleFonts.merriweather(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          unselectedLabelStyle: GoogleFonts.merriweather(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_information),
              label: "Doctors",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: "Patients",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: "Account",
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardScreen() {
    final List<Map<String, dynamic>> services = [
      {
        "name": "Rooms",
        "icon": Icons.meeting_room,
        "page": HospitalRoomPage(hospitalId: widget.hospitalId),
      },
      {
        "name": "Request",
        "icon": Icons.request_page,
        "page": RequestServicePage(hospitalId: widget.hospitalId),
      },
      {
        "name": "Map",
        "icon": Icons.map,
        "page": MapServicePage(hospitalId: widget.hospitalId),
      },
      {
        "name": "Reports",
        "icon": Icons.description,
        "page": ReportScreen(
          hospitalId: widget.hospitalId,
          hospitalName: widget.hospitalName,
        ),
      },
      {
        "name": "Emergency",
        "icon": Icons.emergency,
        "page": EmergencyServicePage(hospitalId: widget.hospitalId),
      },
      {
        "name": "Feedback",
        "icon": Icons.feedback,
        "page": HospitalFeedbackPage(hospitalId: widget.hospitalId),
      },
    ];

  bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.hospitalName}",
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
       child: isDesktop
          ? ListView.separated( // *** UPDATED: Desktop view uses ListView instead of Grid ***
              itemCount: services.length,
              separatorBuilder: (_, __) => SizedBox(height: 25),
              itemBuilder: (context, index) {
                final service = services[index];
                return GestureDetector( // *** UPDATED: wrapped ListTile in GestureDetector to match mobile navigation ***
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => service["page"]),
                    );
                  },
                  child: Container( 
                    height: 70,// *** UPDATED: Gradient background for desktop list item ***
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Color.fromARGB(255, 4, 46, 81)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ListTile(
                        leading: Icon(service["icon"], color: Colors.white, size: 32),
                        title: Text(
                          service["name"],
                          style: GoogleFonts.merriweather(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
                      ),
                    ),
                  ),
                );
              },
            )
          : Padding(
            padding: const EdgeInsets.only(top: 28,right: 5,left: 5),
            child: GridView.builder(
                itemCount: services.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 40,
                  crossAxisSpacing: 25,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final service = services[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => service["page"]),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent, Color.fromARGB(255, 4, 46, 81)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(2, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(service["icon"], color: Colors.white, size: 36),
                            SizedBox(height: 10),
                            Text(
                              service["name"],
                              style: GoogleFonts.mateSc(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ),
    ),
  );
}


  //-------------------- doctor  screen ----------------\\
  Widget _doctorManagementScreen() {
    final nameController = TextEditingController();
    final specializationController = TextEditingController();
    final codeController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Manage Doctors",
          style: GoogleFonts.merriweather(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
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

      body: Padding(
        padding: EdgeInsets.only(top: 35,left: 10,right: 10),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                children: [
                  // Row 1
                  Row(
                    children: [
                      Expanded(
                        child: buildStyledField(nameController, "Doctor Name"),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: buildStyledField(
                          specializationController,
                          "Specialization",
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Row 2
                  Row(
                    children: [
                      Expanded(
                        child: buildStyledField(
                          emailController,
                          "Doctor Email",
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: buildStyledField(
                          passwordController,
                          "Password",
                          obscure: true,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  buildStyledField(codeController, "Hospital Code"),

                  SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Color.fromARGB(255, 6, 33, 55),
                      ),
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty ||
                            specializationController.text.trim().isEmpty ||
                            codeController.text.trim().isEmpty ||
                            emailController.text.trim().isEmpty ||
                            passwordController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please fill all fields")),
                          );
                          return;
                        }

                        String doctorId = Uuid().v4();

                        final doctorData = {
                          "doctorId": doctorId,
                          "name": nameController.text.trim(),
                          "specialization": specializationController.text
                              .trim(),
                          "email": emailController.text.trim(),
                          "password": passwordController.text.trim(),
                          "hospitalId": widget.hospitalId,
                          "hospitalName": widget.hospitalName,
                          "hospitalCode": codeController.text.trim(),
                          "role": "Doctor",
                          "image": "https://via.placeholder.com/400",
                          "createdAt": DateTime.now().toIso8601String(),
                        };

                        //----------------------------- Save doctor inside the hospital/doctor-------------------\\
                        await dbRef
                            .child(
                              "hospitals/${widget.hospitalId}/doctors/$doctorId",
                            )
                            .set(doctorData);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Doctor added successfully")),
                        );

                        nameController.clear();
                        specializationController.clear();
                        codeController.clear();
                        emailController.clear();
                        passwordController.clear();
                      },
                      child: Text(
                        "Add Doctor",
                        style: GoogleFonts.germaniaOne(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            // ------------------- doctor list -------------------\\
            Expanded(
              child: StreamBuilder(
                stream: dbRef
                    .child("hospitals/${widget.hospitalId}/doctors")
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData &&
                      snapshot.data!.snapshot.value != null) {
                    final data = Map<String, dynamic>.from(
                      snapshot.data!.snapshot.value as Map,
                    );

                    final doctors = data.entries.toList();

                    return ListView.builder(
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        final doctorId = doctors[index].key;
                        final doctor = Map<String, dynamic>.from(
                          doctors[index].value,
                        );
                        return Card(
                          elevation: 6,
                          shadowColor: Colors.black54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue,
                                  Color.fromARGB(255, 6, 33, 55),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              leading: CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: Color.fromARGB(255, 4, 46, 81),
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                doctor["name"] ?? "Unknown",
                                style: GoogleFonts.neuton(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "${doctor["specialization"]} || ${doctor["email"]}",
                                style: GoogleFonts.germaniaOne(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                                       //---------------------------- removing doctor-------------------\\
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await dbRef
                                      .child(
                                        "hospitals/${widget.hospitalId}/doctors/$doctorId",
                                      )
                                      .remove();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Doctor removed")),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return Center(child: Text("No doctors added yet."));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

//------------------------------ for the text field---------------------\\
  Widget buildStyledField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.germaniaOne(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.ibarraRealNova(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}
