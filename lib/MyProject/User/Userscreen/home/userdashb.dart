import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virmedo/MyProject/User/Bottomnavigation/Booking/bookingpage.dart';
import 'package:virmedo/MyProject/User/Bottomnavigation/account/accountpage.dart';
import 'package:virmedo/MyProject/User/Bottomnavigation/dashhome/homepg.dart';

class Userdashboard extends StatefulWidget {
  final String userId;
  final String userName;
   
  Userdashboard({super.key, required this.userId, required this.userName,});

  @override
  State<Userdashboard> createState() => __UserdashboardStateState();
}

class __UserdashboardStateState extends State<Userdashboard> {
  int _currentIndex = 0;
  List<Map<String, String>> _appointments = [];

  @override
  void initState() {
    super.initState();
  }

  void _updateAppointments(List<Map<String, String>> appointments) {
    setState(() {
      _appointments = appointments;
    });  
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Homepage(userId: widget.userId, appointments: _appointments),
      Bookingpage(
        userId: widget.userId,
        userName: widget.userName,
       
        onBooked: (newAppointments) {
          setState(() {
            _appointments = newAppointments;
          });
        },
      ),

      Accountpage(),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Hello, ${widget.userName}!",
          style: GoogleFonts.merriweather(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        // leading: Padding(
        //   padding: const EdgeInsets.only(left: 20),
        //   child: Icon(Icons.arrow_back_ios,color: Colors.white,),
        // ),
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

      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 4, 46, 81), Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),


        //-------------------------------bottomnavigation-----------------------------\\
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color.fromARGB(179, 175, 169, 169),
          selectedLabelStyle: GoogleFonts.grenzeGotisch(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.grenzeGotisch(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: "Booking",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
          ],
        ),
      ),
    );
  }
}
