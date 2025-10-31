import 'package:flutter/material.dart';
import 'package:virmedo/MyProject/Admin/Bottomnavigation/page1.dart';
import 'package:virmedo/MyProject/Admin/Bottomnavigation/page2.dart';
import 'package:virmedo/MyProject/Admin/Bottomnavigation/page3.dart';
import 'package:virmedo/MyProject/signup/signupscreen/signupscreen.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [page1(), Page2(), Page3()];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget navItem(IconData icon, String title, int index) {
    final bool selected = _selectedIndex == index;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: TextStyle(color: Colors.white)),
        onTap: () => _onNavTapped(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      body: isMobile ? _buildMobileView(context) : _buildDesktopView(context),
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onNavTapped,
              selectedItemColor:  Color.fromARGB(255, 4, 46, 81),
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              items:  [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_hospital),
                  label: 'Hospitals',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.feedback),
                  label: 'Feedback',
                ),
              ],
            )
          : null,
      floatingActionButton: isMobile
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                  (route) => false,
                );
              },
              backgroundColor: Colors.white,
              icon:  Icon(Icons.logout, color: Colors.redAccent),
              label:  Text(
                "Logout",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDesktopView(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 220,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(5, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Admin Panel",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(color: Colors.white24, thickness: 3),

              navItem(Icons.dashboard, "Dashboard", 0),
              navItem(Icons.local_hospital, "Hospitals", 1),
              navItem(Icons.feedback, "Feedback", 2),

              Spacer(),
              Container(
                decoration: BoxDecoration(color: Colors.transparent),
                child: ListTile(
                  leading:  Icon(
                    Icons.logout,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                  title:  Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
               Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "© 2025 VIRMEDO",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _pages[_selectedIndex]),
      ],
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(child: _pages[_selectedIndex]),
          Padding(
            padding:  EdgeInsets.only(bottom: 12, top: 4, right: 390),
            child: Text(
              "©2025 VIRMEDO",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
