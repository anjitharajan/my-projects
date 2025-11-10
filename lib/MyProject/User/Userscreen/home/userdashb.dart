import 'package:flutter/material.dart';
import 'package:virmedo/MyProject/User/Bottomnavigation/Booking/bookingpage.dart';
import 'package:virmedo/MyProject/User/Bottomnavigation/account/accountpage.dart';
import 'package:virmedo/MyProject/User/Bottomnavigation/dashhome/homepg.dart';

class Userdashboard extends StatefulWidget {
  final String userId;
  final String userName;
   Userdashboard({
    super.key,
    required this.userId,
    required this.userName,
  });

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
        backgroundColor: Color.fromARGB(255, 4, 46, 81).withOpacity(0.10),
        title: Text(
         "Hello, ${widget.userName}!"
,
          style: TextStyle(
            color: Color.fromARGB(255, 4, 46, 81),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),

      body: pages[_currentIndex],
      //   _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Color.fromARGB(255, 4, 46, 81),
          unselectedItemColor: Color.fromARGB(255, 124, 123, 123),
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
  // Widget _buildBody() {
  //   if (_upcomingAppointment != null) {
  //     final apptDateTime = DateTime.parse(_upcomingAppointment!['dateTime']!);
  //     if (apptDateTime.isBefore(DateTime.now())) {
  //       _upcomingAppointment = null;
  //     }
  //   }

  //   switch (_currentIndex) {
  //     case 0:
  //       return _upcomingAppointment != null
  //           ? _buildAppointmentCard(
  //               _upcomingAppointment!['doctorName']!,
  //               _upcomingAppointment!['specialization']!,
  //               _upcomingAppointment!['date']!,
  //               _upcomingAppointment!['time']!,
  //               _upcomingAppointment!['image']!,
  //             )
  //           : _buildNoAppointmentCard();
  //     case 2:
  //       return Accountpage();
  //     default:
  //       return SizedBox();
  //   }
  // }


// Widget _buildAppointmentCard(
//   String doctorName,
//   String specialization,
//   String date,
//   String time,
//   String image,
// ) {
//   return Container(
//     padding: EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(12),
//       color: Colors.yellow,
//       boxShadow: [
//         BoxShadow(color: Colors.grey.shade300, blurRadius: 6, spreadRadius: 2),
//       ],
//     ),
    // child: Row(
    //   children: [
    //     CircleAvatar(radius: 35, backgroundImage: NetworkImage(image)),
    //     SizedBox(width: 15),
    //     Expanded(
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Text(
    //             doctorName,
    //             style: TextStyle(
    //               fontSize: 18,
    //               fontWeight: FontWeight.bold,
    //               color: Colors.black87,
    //             ),
    //           ),
    //           Text(specialization, style: TextStyle(color: Colors.grey[700])),
    //           SizedBox(height: 6),
    //           Text(
    //             " $date   $time",
    //             style: TextStyle(color: Colors.blueGrey[700]),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
//     // ),
//   );
// }

// Widget _buildNoAppointmentCard() {
//   return Container(
//     width: double.infinity,
//     padding: EdgeInsets.symmetric(vertical: 18),
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
//       ),
//       borderRadius: BorderRadius.circular(10),
//       boxShadow: [
//         BoxShadow(color: Colors.grey, blurRadius: 3, spreadRadius: 1),
//       ],
//     ),
//     child: Center(
//       child: Text(
//         "No appointment booked yet",
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     ),
//   );


















