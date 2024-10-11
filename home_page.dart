import 'package:flutter/material.dart';
import 'package:flutter_project3/pages/login_screen.dart';
import 'package:flutter_project3/pages/profile_page.dart';
import 'package:flutter_project3/widgets/bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('ยืนยันการออกจากระบบ'),
                    content: Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
                    actions: [
                      TextButton(
                        child: Text('ยกเลิก'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('ยืนยัน'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ProfilePage(),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }
}
