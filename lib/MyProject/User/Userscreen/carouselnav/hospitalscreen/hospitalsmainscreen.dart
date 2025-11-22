import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/diet.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/emergency.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/map.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/report.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/request.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/Modules/rooms.dart';

class HospitalPage extends StatelessWidget {
  final String hospitalName;
  final String hospitalImage;
  final String aboutText;
  final String hospitalId;
  final String userId;

  const HospitalPage({
    super.key,
    required this.hospitalId,
    required this.hospitalName,
    required this.hospitalImage,
    required this.aboutText,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {"name": "Rooms", "icon": Icons.hotel},
      {"name": "Request", "icon": Icons.request_page},
      {"name": "Map", "icon": Icons.map},
      {"name": "Diet", "icon": Icons.restaurant},
      {"name": "Report", "icon": Icons.folder},
      {"name": "Emergency", "icon": Icons.local_hospital},
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 180,
            backgroundColor: const Color.fromARGB(255, 4, 46, 81),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              "Welcome to ${hospitalName.split(' ')[0]}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(hospitalImage, fit: BoxFit.fill),
            ),
          ),

          // Hospital header section
         SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ----- Hospital Name & About -----
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          hospitalName,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 4, 46, 81),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          aboutText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------- UNLINK HOSPITAL BOX ----------
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Hospital Linked",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 4, 46, 81),
                            ),
                          ),
                          const SizedBox(height: 6),

                          const Text(
                            "You are connected to this hospital.\n"
                            "If you unlink, you will lose access to services until you select a new hospital.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 12),

                          ElevatedButton.icon(
                            onPressed: () async {
                              final root = FirebaseDatabase.instance.ref();

                              // await root
                              //     .child("users/$userId/hospitalStatus/$hospitalId")
                              //     .remove();

                              await root
                                  .child("users/$userId/currentHospitalId")
                                  .remove();
                                    // ✅ MUST REMOVE enabled hospital link
  await root
      .child("users/$userId/enabledHospitals/$hospitalId")
      .remove();

                              Navigator.pop(context);
                            },
                            icon:
                                const Icon(Icons.link_off, color: Colors.white),
                            label: const Text(
                              "Unlink Hospital",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ------------------------ SERVICES GRID ------------------------
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final service = services[index];

                  return GestureDetector(
                    onTap: () {
                      switch (service["name"]) {
                        case "Rooms":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => RoomScreen(userId: userId)),
                          );
                          break;

                        case "Diet":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DietScreen(userId: userId, hospitalId: hospitalId),
                            ),
                          );
                          break;

                        case "Report":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserReportScreen(
                                userId: userId,
                                hospitalId: hospitalId,
                                hospitalName: hospitalName,
                              ),
                            ),
                          );
                          break;

                        case "Request":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RequestScreen(
                                hospitalId: hospitalId,
                                userId: userId,
                              ),
                            ),
                          );
                          break;

                        case "Map":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserMapScreen(hospitalId: hospitalId),
                            ),
                          );
                          break;

                        case "Emergency":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EmergencyScreen(
                                hospitalId: hospitalId,
                                userId: userId,
                              ),
                            ),
                          );
                          break;
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.blueAccent,
                            Color.fromARGB(255, 4, 46, 81),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: const [
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
                            Icon(service["icon"],
                                color: Colors.white, size: 35),
                            const SizedBox(height: 8),
                            Text(
                              service["name"],
                              style: const TextStyle(
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
                childCount: services.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}