import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/diet.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/emergency.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/map.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/report.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/request.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/rooms.dart';

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
        print("Connected users for ${widget.hospitalName}: $connectedUsers");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        "name": "Diet",
        "icon": Icons.restaurant_menu,
        "page": DietScreen(hospitalId: widget.hospitalId),
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 180,
            backgroundColor: Color.fromARGB(255, 4, 46, 81),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              "Welcome to ${widget.hospitalName.split(' ')[0]}",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(widget.hospitalImage, fit: BoxFit.fill),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    widget.hospitalName,
                    style: TextStyle(
                      color: Color.fromARGB(255, 4, 46, 81),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.aboutText,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final service = services[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => service["page"]),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent,
                          Color.fromARGB(255, 4, 46, 81),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
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
              }, childCount: services.length),
            ),
          ),
        ],
      ),
    );
  }
}
