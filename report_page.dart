import 'package:flutter/material.dart'; // Import widget พื้นฐานของ Flutter
import 'package:flutter_project3/widgets/bottom_nav_bar.dart'; // Import BottomNavBar
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth package

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _reportController =
      TextEditingController(); // ตัวควบคุมสำหรับรับข้อความรายงาน
  String _selectedRoom = 'ห้องประชุมเล็ก(สำหรับ1-4คน)'; // ห้องประชุมที่เลือก

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รายงาน')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ปัญหาระหว่างการใช้งานห้องประชุม',
              style: TextStyle(fontSize: 24, color: Colors.blue),
            ),
            SizedBox(height: 20), // เพิ่มระยะห่าง
            Text(
              'ผู้ใช้สามารถกรอกรายงานปัญหาที่พบเจอ',
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
            SizedBox(height: 20), // เพิ่มระยะห่าง
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'ประเภทของห้อง',
                filled: true,
                fillColor: Color(0xFFF8F3F8), // ตั้งค่าสีพื้นหลัง
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey, // สีเส้นใต้
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey, // สีเส้นใต้
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue, // สีเส้นใต้เมื่อ focus
                  ),
                ),
              ),
              value: _selectedRoom,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRoom = newValue!;
                });
              },
              items: <String>[
                'ห้องประชุมเล็ก(สำหรับ1-4คน)',
                'ห้องประชุมใหญ่(สำหรับ5-10คน)',
                'ห้องสัมมนา(10คนขึ้นไป)'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20), // เพิ่มระยะห่าง
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('รายงานปัญหา'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller:
                                _reportController, // เพิ่ม controller สำหรับรับข้อความ
                            decoration: InputDecoration(
                              hintText: 'กรอกรายละเอียดปัญหา',
                            ),
                            // อนุญาตให้พิมพ์หลายบรรทัด
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text('ส่งรายงาน'),
                          onPressed: () {
                            _submitReport(
                                context); // เรียกฟังก์ชันส่งรายงานไปยัง Firebase
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('รายงานปัญหา'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 4),
    );
  }

  // ฟังก์ชันสำหรับส่งรายงานไปยัง Firebase
  Future<void> _submitReport(BuildContext context) async {
    final User? user =
        FirebaseAuth.instance.currentUser; // รับข้อมูลผู้ใช้ที่เข้าสู่ระบบ
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเข้าสู่ระบบเพื่อส่งรายงาน')),
      );
      return;
    }

    String reportText = _reportController.text; // ข้อความรายงานจาก TextField
    if (reportText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกรายละเอียดปัญหา')),
      );
      return;
    }

    try {
      // บันทึกรายงานลงใน Firestore
      await FirebaseFirestore.instance.collection('reports').add({
        'userId': user.uid,
        'room': _selectedRoom, // ห้องที่เลือก
        'report': reportText,
        'timestamp': FieldValue.serverTimestamp(), // เวลาที่รายงาน
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ส่งรายงานปัญหาแล้ว')),
      );
      _reportController.clear(); // ล้างข้อความหลังจากส่งรายงานสำเร็จ
      Navigator.of(context).pop(); // ปิด dialog
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }
}
