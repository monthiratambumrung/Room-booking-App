import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      return doc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('โปรไฟล์'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('ไม่พบข้อมูลผู้ใช้งาน'));
            }

            var userData = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  ProfileAvatar(),
                  SizedBox(height: 10),
                  ProfileButton(),
                  SizedBox(height: 20),
                  ProfileForm(
                    name: userData['name'],
                    lastName: userData['last name'],
                    email: userData['email'],
                    phone: userData['telephone number'],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.lightBlue[100],
      child: CircleAvatar(
        radius: 48,
        backgroundImage: AssetImage('assets/profile_image.png'),
        onBackgroundImageError: (exception, stackTrace) {
          print('Error loading profile image: $exception');
        },
      ),
    );
  }
}

class ProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('ข้อมูลของฉัน', style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: () {},
    );
  }
}

class ProfileForm extends StatelessWidget {
  final String name;
  final String lastName;
  final String email;
  final String phone;

  ProfileForm({
    required this.name,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          CustomTextField(label: 'ชื่อ', hintText: name),
          SizedBox(height: 15),
          CustomTextField(label: 'นามสกุล', hintText: lastName),
          SizedBox(height: 15),
          CustomTextField(label: 'Email', hintText: email),
          SizedBox(height: 15),
          CustomTextField(label: 'เบอร์โทรศัพท์', hintText: phone),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;

  CustomTextField({required this.label, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.lightBlue[300]!),
            ),
          ),
        ),
      ],
    );
  }
}
