import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project3/widgets/bottom_nav_bar.dart';
import 'package:flutter_project3/pages/edit_booking_page.dart';
import 'package:intl/intl.dart'; // เพิ่มเพื่อจัดรูปแบบวันที่

class BookingDetailsPage extends StatelessWidget {
  // ฟังก์ชันสำหรับดึงข้อมูลการจองจาก Firestore
  Stream<QuerySnapshot> _getBookingDetails() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('booking')
          .doc(user.uid) // ใช้ UID ของผู้ใช้เป็น document ID
          .collection('room') // ใช้ subCollection 'room'
          .snapshots();
    } else {
      // ถ้าไม่มีผู้ใช้ล็อกอิน จะส่งคืนสตรีมที่ไม่มีข้อมูล
      return Stream.empty();
    }
  }

  // ฟังก์ชันสำหรับลบรายการ
  void _deleteBooking(String docId) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('booking')
          .doc(user.uid)
          .collection('room')
          .doc(docId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รายละเอียดการจอง')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _getBookingDetails(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('ไม่มีรายละเอียดการจอง'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;

                // แปลงข้อมูลวันที่ให้เป็นรูปแบบที่ต้องการ
                DateTime bookingDate = data['bookingDate'].toDate();
                String formattedDate = DateFormat('dd/MM/yyyy')
                    .format(bookingDate); // รูปแบบวันที่เป็น วัน/เดือน/ปี

                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  title: Text('เวลา: ${data['time']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('จำนวนผู้ใช้งาน: ${data['userCount']}'),
                      Text('ประเภทของห้อง: ${data['roomType']}'),
                      Text(
                          'บันทึกเมื่อ: $formattedDate'), // แสดงเฉพาะวันเดือนปี
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditListBookingPage(
                                docId: document.id,
                                initialData: data,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // ยืนยันการลบ
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('ยืนยันการลบ'),
                                content: Text('คุณต้องการลบรายการนี้หรือไม่?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // ปิด dialog
                                    },
                                    child: Text('ยกเลิก'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteBooking(document.id); // ลบรายการ
                                      Navigator.of(context).pop(); // ปิด dialog
                                    },
                                    child: Text('ลบ'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
    );
  }
}
