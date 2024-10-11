import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_project3/widgets/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> bookings = []; // List to store bookings
  String? uid; // To store the user's UID

  @override
  void initState() {
    super.initState();
    _getCurrentUserUid();
  }

  // Function to get the current user's UID
  void _getCurrentUserUid() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          uid = user.uid;
        });
        print("User UID: $uid");
      } else {
        print("No user is currently logged in.");
      }
    } catch (e) {
      print("Error getting user UID: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ปฏิทินการจอง', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _fetchBookingsForSelectedDay();
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blue),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.red),
              outsideTextStyle: TextStyle(color: Colors.grey),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                Color textColor = Colors.black; // Default color
                String status = '';

                if (day.isBefore(DateTime.now())) {
                  textColor = Colors.red;
                  status = 'ผ่านไปแล้ว';
                } else {
                  textColor = Colors.green;
                  status = 'จองได้';
                  // Check if there are bookings for that day
                  bool hasBookings = bookings.any((booking) =>
                      (booking['bookingDate'] as Timestamp)
                          .toDate()
                          .isSameDay(day));

                  if (hasBookings) {
                    textColor = Colors.yellow;
                  }
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(color: textColor),
                      ),
                      if (status.isNotEmpty)
                        Text(
                          status,
                          style: TextStyle(color: textColor, fontSize: 10),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Text(
            'จำนวนการจองในระบบทั้งหมด: ${bookings.length} รายการ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          bookings.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          child: ExpansionTile(
                            title: Text(
                              'Room Type: ${booking['roomType']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Name: ${booking['userName'] ?? ''}',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              Text(
                                                'Time: ${booking['time']}',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Last Name: ${booking['userLastName'] ?? ''}',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              Text(
                                                'Count: ${booking['userCount']}',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Telephone: ${booking['userPhone'] ?? ''}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Text('ไม่มีการจองในวันที่เลือก'),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
    );
  }

  // Function to fetch bookings from Firestore based on selected day
  void _fetchBookingsForSelectedDay() async {
    if (_selectedDay != null) {
      try {
        DateTime startOfDay = DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
        );
        DateTime endOfDay = DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
          23,
          59,
          59,
          999,
        );

        print("Fetching bookings for date: $_selectedDay");

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collectionGroup('room')
            .where('bookingDate', isGreaterThanOrEqualTo: startOfDay)
            .where('bookingDate', isLessThanOrEqualTo: endOfDay)
            .get();

        setState(() {
          bookings = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });

        if (bookings.isEmpty) {
          print("No bookings found for the selected date.");
        } else {
          print("Bookings found: ${bookings.length}");
        }
      } catch (e) {
        print("Error fetching bookings: $e");
      }
    } else {
      print("Selected day is null.");
    }
  }
}

// Extension to compare two DateTime objects for equality
extension DateTimeCompare on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
