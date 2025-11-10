import 'package:flutter/material.dart';

class HospitalPage extends StatelessWidget {
  final String hospitalName;
  final String hospitalImage;
  final String aboutText;

  HospitalPage({
    super.key,
    required this.hospitalName,
    required this.hospitalImage,
    required this.aboutText,
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
            backgroundColor: Color.fromARGB(255, 4, 46, 81),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              "Welcome to ${hospitalName.split(' ')[0]}",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(hospitalImage, fit: BoxFit.fill),
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
                    "$hospitalName",
                    style: TextStyle(
                      color: Color.fromARGB(255, 4, 46, 81),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    aboutText,
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
                return Container(
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
                        Text(service["icon"]!, style: TextStyle(fontSize: 30)),
                        SizedBox(height: 8),
                        Text(
                          service["name"]!,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
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
