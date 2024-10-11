import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project3/widgets/bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class EditBookingPage extends StatefulWidget {
  @override
  _EditBookingPageState createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  final TextEditingController _userCountController = TextEditingController();
  String? _selectedTime;
  String? _selectedRoomType;
  DateTime? _selectedDate;

  // ตัวแปรสำหรับเก็บข้อมูลผู้ใช้
  String? _userName;
  String? _userLastName;
  String? _userPhone;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // เรียกฟังก์ชันดึงข้อมูลผู้ใช้
  }

  // ฟังก์ชันสำหรับดึงข้อมูลผู้ใช้จาก Firestore
  Future<void> _fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['name'];
          _userLastName = userDoc['last name'];
          _userPhone = userDoc['telephone number'];
        });
      }
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveBooking() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนทำการจอง')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเลือกวันที่')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('booking')
          .doc(user.uid)
          .collection('room')
          .add({
        'userCount': _userCountController.text,
        'time': _selectedTime,
        'roomType': _selectedRoomType,
        'bookingDate': _selectedDate,
        'userName': _userName, // ส่งชื่อผู้ใช้
        'userLastName': _userLastName, // ส่งนามสกุล
        'userPhone': _userPhone, // ส่งหมายเลขโทรศัพท์
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึกการจองแล้ว')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึก: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รายละเอียดการจอง')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('รายละเอียดการจอง',
                style: TextStyle(fontSize: 24, color: Colors.blue)),
            TextField(
              controller: _userCountController,
              decoration: InputDecoration(labelText: 'จำนวนผู้ใช้งาน'),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'เวลา'),
              isExpanded: true,
              items: [
                '8:00',
                '9:00',
                '10:00',
                '11:00',
                '12:00',
                '13:00',
                '14:00',
                '15:00',
                '16:00'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTime = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'ประเภทของห้อง'),
              isExpanded: true,
              items: [
                'ห้องประชุมเล็ก(สำหรับ1-4คน)',
                'ห้องประชุมใหญ่(สำหรับ5-10คน)',
                'ห้องสัมมนา(10คนขึ้นไป)'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRoomType = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickDate,
              child: Text(_selectedDate == null
                  ? 'เลือกวันที่'
                  : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveBooking,
              child: Text('บันทึกการจอง'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
    );
  }
}
