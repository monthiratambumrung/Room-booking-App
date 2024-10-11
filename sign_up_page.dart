import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _registerUser(BuildContext context) async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('รหัสผ่านไม่ตรงกัน')),
      );
      return;
    }

    final email = _emailController.text;
    final password = _passwordController.text;

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('อีเมลไม่ถูกต้อง')),
      );
      return;
    }

    try {
      // Register user with Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If sign up is successful, save additional user info to Firestore
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      await users.doc(userCredential.user?.uid).set({
        'name': _nameController.text,
        'last name': _lastNameController.text,
        'telephone number': _phoneController.text,
        'email': email,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('สมัครผู้ใช้งานสำเร็จ')),
      );

      Navigator.pop(context); // กลับไปที่หน้าก่อนหน้า
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('สมัครผู้ใช้งาน',
            style: TextStyle(fontSize: 24, color: Colors.blue)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'ชื่อ'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'นามสกุล'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'เบอร์โทรศัพท์'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'อีเมล'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'รหัสผ่าน'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'ยืนยันรหัสผ่าน'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _registerUser(context),
              child: Text('สมัครผู้ใช้งาน'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
