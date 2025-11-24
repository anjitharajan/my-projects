import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class Page2 extends StatefulWidget {
  Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("hospitals");
  List<Map<String, dynamic>> hospitals = [];

  @override
  void initState() {
    super.initState();
    fetchHospitals();
  }

  void fetchHospitals() {
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final List<Map<String, dynamic>> tempList = [];
        data.forEach((key, value) {
          tempList.add({
            'id': key,
            'name': value['name'] ?? '',
            'address': value['address'] ?? '',
            'code': value['code'] ?? '',
            'contact': value['contact'] ?? '',
          });
        });
        setState(() {
          hospitals = tempList;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 60.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
           borderRadius: BorderRadius.circular(isMobile ? 10 : 16), 
          boxShadow: [BoxShadow(color: Colors.black, blurRadius: 8)],
        ),
         padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        //  mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Registered Hospitals",
              style: GoogleFonts.merriweather(
                fontSize: isMobile ? 20 : 26,  
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),

              SizedBox(height: isMobile ? 15 : 20),

            Container(height: 2, width: double.infinity, color: Colors.white24),

                 SizedBox(height: isMobile ? 15 : 20),


             Expanded(
              child: isMobile
                  ? buildMobileList()  // ********* MOBILE VIEW *********
                  : buildDesktopTable(), // ********* DESKTOP VIEW *********
            ),
          ],
        ),
      ),
    );
  }

  /// ***************************************
  ///           DESKTOP TABLE VIEW
  /// ***************************************
  Widget buildDesktopTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(
              label: Text(
                "Name",
                style: GoogleFonts.gloock(color: Colors.white, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Address",
                style: GoogleFonts.gloock(color: Colors.white, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Code",
                style: GoogleFonts.gloock(color: Colors.white, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Contact",
                style: GoogleFonts.gloock(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
          rows: hospitals.map((h) {
            return DataRow(
              cells: [
                DataCell(Text(h['name'], style: tableTextStyle())),
                DataCell(Text(h['address'], style: tableTextStyle())),
                DataCell(Text(h['code'], style: tableTextStyle())),
                DataCell(Text(h['contact'], style: tableTextStyle())),
              ],
            );
          }).toList(),
          columnSpacing: 60,
          dataRowHeight: 60,
          headingRowHeight: 60,
          dividerThickness: 1.3,
          showBottomBorder: true,
        ),
      ),
    );
  }

  /// ***************************************
  ///           MOBILE LIST VIEW
  /// ***************************************
Widget buildMobileList() {
  return ListView.builder(
    physics: BouncingScrollPhysics(),
    itemCount: hospitals.length,
    itemBuilder: (context, i) {
      final item = hospitals[i];

      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Optional: show details dialog / open new page
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              title: Text(item['name']),
              content: Text(
                "Address: ${item['address']}\n"
                "Code: ${item['code']}\n"
                "Contact: ${item['contact']}",
              ),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.20),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hospital header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      child:
                          Icon(Icons.local_hospital, color: Colors.white, size: 22),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['name'],
                        style: GoogleFonts.merriweather(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Info items
                buildMobileInfo("Address", item['address'], Icons.location_on),
                SizedBox(height: 8),
                buildMobileInfo("Code", item['code'], Icons.qr_code_2),
                SizedBox(height: 8),
                buildMobileInfo("Contact", item['contact'], Icons.phone),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget buildMobileInfo(String title, String value, IconData icon) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Colors.white70, size: 18),
      SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.gloock(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.gupter(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

  TextStyle tableTextStyle() {
    return GoogleFonts.gupter(
      color: Colors.white70,
      fontSize: 15,
    );
  }
}