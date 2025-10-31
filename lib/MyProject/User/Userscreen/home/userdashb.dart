import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:virmedo/MyProject/User/Bottomnavigation/Booking/bookingpage.dart';
import 'package:virmedo/MyProject/User/Bottomnavigation/account/accountpage.dart';
import 'package:virmedo/MyProject/User/Bottomnavigation/account/medicalrcd.dart';
import 'package:virmedo/MyProject/User/Medicalrecord/medicalrecord.dart';
import 'package:virmedo/MyProject/User/Userscreen/carouselnav/enablescreen/hospitalenable.dart';

class Userdashboard extends StatefulWidget {
  Userdashboard({super.key});

  @override
  State<Userdashboard> createState() => __UserdashboardStateState();
}

class __UserdashboardStateState extends State<Userdashboard> {
  int _currentIndex = 0;
  Map<String, String>? _upcomingAppointment;

  late List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pages = [
      Homepage(appointment: _upcomingAppointment),
      Bookingpage(
        onBooked: (appointment) {
          setState(() {
            _upcomingAppointment = appointment.isNotEmpty
                ? appointment[0]
                : null;

            _pages[0] = Homepage(appointment: _upcomingAppointment);
          });
        },
      ),
      Accountpage(),
    ];
  }

  final List<String> _titles = [
    "Hello, Anjitha Rajan!",
    "My Bookings",
    "My Account",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // elevation: 0,

        //       leading: IconButton(
        //   icon:  Icon(
        //     Icons.arrow_back_ios,
        //     color: Color.fromARGB(255, 4, 46, 81),
        //   ),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
        centerTitle: true,

        // actions: [
        //   Padding(
        //     padding: EdgeInsets.only(right: 16),
        //     child: Icon(
        //       Icons.settings_outlined,
        //       color: Color.fromARGB(255, 4, 46, 81),
        //     ),
        //   ),
        // ],
        backgroundColor: Color.fromARGB(255, 4, 46, 81).withOpacity(0.10),
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(
            color: Color.fromARGB(255, 4, 46, 81),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: _pages[_currentIndex],
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
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Bookingpage(
                    onBooked: (appointment) {
                      DateTime now = DateTime.now();
                      appointment.sort((a, b) {
                        DateTime dtA = DateTime.parse(a['dateTime']!);
                        DateTime dtB = DateTime.parse(b['dateTime']!);
                        return dtA.compareTo(dtB);
                      });

                      final nextAppointment = appointment.firstWhere(
                        (a) => DateTime.parse(a['dateTime']!).isAfter(now),
                        orElse: () => {},
                      );
                      setState(() {
                        _upcomingAppointment = nextAppointment.isNotEmpty
                            ? nextAppointment
                            : null;
                      });
                    },
                  ),
                ),
              );
            } else {
              setState(() => _currentIndex = index);
            }
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

  Widget _buildBody() {
    if (_upcomingAppointment != null) {
      final apptDateTime = DateTime.parse(_upcomingAppointment!['dateTime']!);
      if (apptDateTime.isBefore(DateTime.now())) {
        _upcomingAppointment = null;
      }
    }

    switch (_currentIndex) {
      case 0:
        return _upcomingAppointment != null
            ? _buildAppointmentCard(
                _upcomingAppointment!['doctorName']!,
                _upcomingAppointment!['specialization']!,
                _upcomingAppointment!['date']!,
                _upcomingAppointment!['time']!,
                _upcomingAppointment!['image']!,
              )
            : _buildNoAppointmentCard();
      case 2:
        return Accountpage();
      default:
        return SizedBox();
    }
  }
}

Widget _buildAppointmentCard(
  String doctorName,
  String specialization,
  String date,
  String time,
  String image,
) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.yellow,
      boxShadow: [
        BoxShadow(color: Colors.grey.shade300, blurRadius: 6, spreadRadius: 2),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(radius: 35, backgroundImage: NetworkImage(image)),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctorName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(specialization, style: TextStyle(color: Colors.grey[700])),
              SizedBox(height: 6),
              Text(
                " $date   $time",
                style: TextStyle(color: Colors.blueGrey[700]),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildNoAppointmentCard() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: 18),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
      ),
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(color: Colors.grey, blurRadius: 3, spreadRadius: 1),
      ],
    ),
    child: Center(
      child: Text(
        "No appointment booked yet",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

class Homepage extends StatelessWidget {
  final Map<String, String>? appointment;

  Homepage({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> Hospitals = [
      {
        "name": "Medical Trust Hospital",
        "image":
            "data:image/jpeg;base64,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",
      },
      {
        "name": "Renai Medicity Hospital",
        "image":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqiW0KMsGsZHuve8dnIUxU9lM_OUYxnwUlmg&s",
      },
      {
        "name": "Welcare Hospital",
        "image":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZVjaLBODwDcAurHoWU5QiISMlsVZyEQnufA&s",
      },
      {
        "name": "Lakeshore Hospital",
        "image": "https://i.ytimg.com/vi/0tMQ0xvqfDc/maxresdefault.jpg",
      },
      {
        "name": "Aster Medicity Hospital",
        "image":
            "https://thumbnails.icloudhospital.com/tr:w-1536,f-webp,q-75/c9442768c645bed9218d90d47dff5a4b-9f569b04-e115-407d-9575-2e8c54459340.webp",
      },
    ];
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Color.fromARGB(255, 4, 46, 81)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 20, top: 1),
                    child: Icon(
                      Icons.search,
                      color: Color.fromARGB(255, 210, 218, 242),
                    ),
                  ),
                  hintText: "Search",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 210, 218, 242),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            SizedBox(height: 25),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => medicalrcdscreen()),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 3,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "My Medical Records",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "Upcoming Appointment",
                style: TextStyle(
                  color: Color.fromARGB(255, 4, 46, 81),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 5),

            appointment != null
                ? _buildAppointmentCard(
                    appointment!['doctorName']!,
                    appointment!['specialization']!,
                    appointment!['date']!,
                    appointment!['time']!,
                    appointment!['image']!,
                  )
                : _buildNoAppointmentCard(),

            SizedBox(height: 30),
            Center(
              child: Text(
                "Nearby Hospitals",
                style: TextStyle(
                  color: Color.fromARGB(255, 4, 46, 81),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 5),
            CarouselSlider(
              options: CarouselOptions(
                height: 260,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.75,
              ),
              items: Hospitals.map((hospital) {
                return Builder(
                  builder: (context) {
                    return GestureDetector(
                      onTap: () async {
                        final enabledHospital = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Enablescreen(
                              hospitalId: hospital["id"]!,
                              hospitalName: hospital["name"]!,
                              hospitalImage: hospital["image"]!,
                              aboutText:
                                  hospital["about"] ??
                                  "Trusted healthcare partner for your wellness journey.",
                            ),
                          ),
                        );

                        if (enabledHospital != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "$enabledHospital enabled successfully",
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color.fromARGB(255, 4, 46, 81),
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(hospital["image"]!),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          alignment: Alignment.bottomLeft,
                          padding: EdgeInsets.all(12),
                          child: Text(
                            hospital["name"]!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
