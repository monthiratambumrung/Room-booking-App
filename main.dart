import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_project3/services/firebase_options.dart';
import 'package:flutter_project3/pages/login_screen.dart';
import 'package:flutter_project3/pages/profile_page.dart';
import 'package:flutter_project3/pages/booking_details_page.dart';
import 'package:flutter_project3/pages/calendar_page.dart';
import 'package:flutter_project3/pages/booking_room.dart';
import 'package:flutter_project3/pages/report_page.dart';
import 'package:flutter_project3/pages/sign_up_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(), // เริ่มต้นที่หน้า LoginScreen
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpPage(),
        '/profile': (context) => ProfilePage(),
        '/calendar': (context) => CalendarPage(),
        '/booking_details': (context) => BookingDetailsPage(),
        '/edit_booking': (context) => EditBookingPage(),
        '/report': (context) => ReportPage(),
      },
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.login), label: 'ล็อคอิน'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_add), label: 'สมัครผู้ใช้งาน'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), label: 'ปฏิทิน'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'รายการ'),
        BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'แก้ไข'),
        BottomNavigationBarItem(icon: Icon(Icons.report), label: 'รายงาน'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/login');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/signup');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/calendar');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/booking_details');
            break;
          case 5:
            Navigator.pushReplacementNamed(context, '/edit_booking');
            break;
          case 6:
            Navigator.pushReplacementNamed(context, '/report');
            break;
        }
      },
    );
  }
}
