import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project3/widgets/bottom_nav_bar.dart';
import 'package:intl/intl.dart'; // เพิ่มเพื่อจัดรูปแบบวันที่

class EditListBookingPage extends StatefulWidget {
  final String docId; // รับ docId ที่จะใช้ในการอัปเดต
  final Map<String, dynamic> initialData; // รับข้อมูลเริ่มต้นสำหรับกรอกในฟอร์ม

  EditListBookingPage({required this.docId, required this.initialData});

  @override
  _EditListBookingPageState createState() => _EditListBookingPageState();
}

class _EditListBookingPageState extends State<EditListBookingPage> {
  late TextEditingController _userCountController;
  String? _selectedTime;
  String? _selectedRoomType;
  DateTime? _selectedDate; // ตัวแปรสำหรับเก็บวันที่ที่เลือก

  @override
  void initState() {
    super.initState();
    // ตั้งค่าข้อมูลเริ่มต้น
    _userCountController =
        TextEditingController(text: widget.initialData['userCount']);
    _selectedTime = widget.initialData['time'];
    _selectedRoomType = widget.initialData['roomType'];
    _selectedDate =
        widget.initialData['bookingDate']?.toDate(); // วันที่เริ่มต้น
  }

  // ฟังก์ชันสำหรับเลือกวันที่
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // ฟังก์ชันสำหรับบันทึกการอัปเดตการจอง
  Future<void> _updateBooking() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนทำการแก้ไข')),
      );
      return;
    }

    // อัปเดตข้อมูลการจองใน Firestore
    try {
      await FirebaseFirestore.instance
          .collection('booking')
          .doc(user.uid)
          .collection('room')
          .doc(widget.docId) // อัปเดตเอกสารที่มี docId ที่ส่งมา
          .update({
        'userCount': _userCountController.text,
        'time': _selectedTime,
        'roomType': _selectedRoomType,
        'bookingDate': _selectedDate, // อัปเดตวันที่ที่เลือก
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('อัปเดตการจองแล้ว')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการอัปเดต: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('แก้ไขการจอง')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('แก้ไขรายละเอียดการจอง',
                style: TextStyle(fontSize: 24, color: Colors.blue)),
            TextField(
              controller: _userCountController,
              decoration: InputDecoration(labelText: 'จำนวนผู้ใช้งาน'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedTime, // ตั้งค่าเริ่มต้น
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
              value: _selectedRoomType, // ตั้งค่าเริ่มต้น
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
            Row(
              children: [
                Text(
                  _selectedDate != null
                      ? 'วันที่: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'
                      : 'ยังไม่ได้เลือกวันที่',
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context), // เปิด DatePicker
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateBooking, // เมื่อกดปุ่มจะอัปเดตการจอง
              child: Text('บันทึกการแก้ไข'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
    );
  }
}
