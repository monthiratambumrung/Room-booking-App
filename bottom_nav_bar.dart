import 'package:flutter/material.dart';
import 'package:flutter_project3/pages/calendar_page.dart';
import 'package:flutter_project3/pages/booking_details_page.dart';
import 'package:flutter_project3/pages/booking_room.dart';
import 'package:flutter_project3/pages/home_page.dart';
import 'package:flutter_project3/pages/report_page.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), label: 'ปฏิทิน'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'รายการ'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'การจอง'),
        BottomNavigationBarItem(icon: Icon(Icons.report), label: 'รายงาน'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
            );
            break;
          case 1:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => CalendarPage()),
              (Route<dynamic> route) => false,
            );
            break;
          case 2:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => BookingDetailsPage()),
              (Route<dynamic> route) => false,
            );
            break;
          case 3:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => EditBookingPage()),
              (Route<dynamic> route) => false,
            );
            break;
          case 4:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ReportPage()),
              (Route<dynamic> route) => false,
            );
            break;
        }
      },
    );
  }
}
