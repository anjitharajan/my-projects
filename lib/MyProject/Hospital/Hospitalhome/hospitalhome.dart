import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:virmedo/MyProject/Hospital/bottomnavigation/haccountpage.dart';
import 'package:virmedo/MyProject/Hospital/bottomnavigation/hpatientpage.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/rooms.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/request.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/map.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/report.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/emergency.dart';
import 'package:virmedo/MyProject/signup/signupscreen/signupscreen.dart';

class HospitalMainPage extends StatefulWidget {
  final String hospitalId;
  final String hospitalName;
  final String hospitalImage;
  final String aboutText;

  HospitalMainPage({
    super.key,
    required this.hospitalId,
    required this.hospitalName,
    required this.hospitalImage,
    required this.aboutText,
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
      PatientPage(),
      AccountPage(),
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(color: Colors.white24),
          _sidebarItem(Icons.dashboard, "Dashboard", 0),
          _sidebarItem(Icons.medical_information, "Doctors", 1),
          _sidebarItem(Icons.people, "Patients", 2),
          _sidebarItem(Icons.account_circle, "Account", 3),
          Spacer(),
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "© 2025 VIRMEDO",
              style: TextStyle(color: Colors.white54, fontSize: 12),
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
          title: Text(title, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      backgroundColor: Color.fromARGB(255, 4, 46, 81),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_information),
          label: "Doctors",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Patients"),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: "Account",
        ),
      ],
    );
  }

  Widget _dashboardScreen() {
    final List<Map<String, dynamic>> services = [
      {
        "name": "Rooms",
        "icon": Icons.meeting_room,
        "page": RoomScreen(hospitalId: widget.hospitalId),
      },
      {
        "name": "Request",
        "icon": Icons.request_page,
        "page": RequestScreen(hospitalId: widget.hospitalId),
      },
      {
        "name": "Map",
        "icon": Icons.map,
        "page": MapScreen(hospitalId: widget.hospitalId),
      },
      {
        "name": "Report",
        "icon": Icons.description,
        "page": ReportScreen(hospitalId: widget.hospitalId),
      },
      {
        "name": "Emergency",
        "icon": Icons.emergency,
        "page": EmergencyScreen(hospitalId: widget.hospitalId),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.hospitalName} Dashboard"),
        backgroundColor: Color.fromARGB(255, 4, 46, 81),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: services.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
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
            );
          },
        ),
      ),
    );
  }

  Widget _doctorManagementScreen() {
    final TextEditingController nameController = TextEditingController();

    final TextEditingController specializationController =
        TextEditingController();
    final TextEditingController codeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Doctors"),
        backgroundColor: Color.fromARGB(255, 4, 46, 81),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Doctor Name"),
            ),

            TextField(
              controller: specializationController,
              decoration: InputDecoration(labelText: "Specialization"),
            ),
            TextField(
              controller: codeController,
              decoration: InputDecoration(labelText: "Hospital Code"),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 4, 46, 81),
              ),
              onPressed: () async {


        
                String doctorId = const Uuid().v4();
                final doctorData = {
                  "id": doctorId,
                  "name": nameController.text.trim(),
                  

                  "specialization": specializationController.text.trim(),
                  "hospitalName": widget.hospitalName,
                  "hospitalId": widget.hospitalId,
                  "hospitalCode": codeController.text.trim(),
                  "role": "Doctor",
                  "image": "https://via.placeholder.com/400",
                  "createdAt": DateTime.now().toIso8601String(),
                };

             
                await dbRef.child("doctors/$doctorId").set(doctorData);

                await dbRef
                    .child("hospitals/${widget.hospitalId}/doctors/$doctorId")
                    .set(doctorData);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Doctor added successfully")),
                );

           
                nameController.clear();
                specializationController.clear();
                codeController.clear();
              },

              child: Text("Add Doctor"),
            ),
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
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>,
                    );
                    final doctors = data.values.toList();

                    return ListView.builder(
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = Map<String, dynamic>.from(
                          doctors[index],
                        );
                        return ListTile(
                          leading: Icon(Icons.person),
                          title: Text(doctor['name']),
                          subtitle: Text(
                            "${doctor['specialization']} | ${doctor['email']}",
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text("No doctors added yet."));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
