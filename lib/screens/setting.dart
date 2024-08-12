import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_card/login_provider.dart';
import 'package:app_card/screens/login.dart';
import 'package:app_card/screens/account.dart';
import 'package:app_card/screens/friendstatus.dart';
import 'package:app_card/screens/history.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<LoginProvider>(context, listen: false).login?.id;
    final userRole =
        Provider.of<LoginProvider>(context, listen: false).login?.role;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('ตั้งค่า'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (userRole !=
                'employee') // ตรวจสอบว่าบทบาทของผู้ใช้ไม่ใช่ 'employee'
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('บัญชี'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountScreen()),
                  );
                },
              ),
            if (userRole !=
                'employee') // ตรวจสอบว่าบทบาทของผู้ใช้ไม่ใช่ 'employee'
              Divider(),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('ประวัติ'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CombinedScreen(userId: userId!)),
                );
              },
            ),
            Divider(),
            // ListTile(
            //   leading: Icon(Icons.bar_chart),
            //   title: Text('สถิติเพื่อน'),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => FriendStatsScreen(userId: userId!)),
            //     );
            //   },
            // ),
            // Divider(),
            ListTile(
              leading: Icon(Icons.logout), // ไอคอนสำหรับออกจากระบบ
              title: Text('ออกจากระบบ'), // ข้อความสำหรับออกจากระบบ
              onTap: () {
                // แสดงกล่องโต้ตอบยืนยันก่อนออกจากระบบ
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('ออกจากระบบ'),
                      content: Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('ยกเลิก'),
                          onPressed: () {
                            Navigator.of(context).pop(); // ปิดกล่องโต้ตอบ
                          },
                        ),
                        TextButton(
                          child: Text('ออกจากระบบ'),
                          onPressed: () {
                            // ตรรกะการออกจากระบบที่นี่
                            Provider.of<LoginProvider>(context, listen: false)
                                .logout();

                            // นำทางไปยังหน้าจอล็อกอิน
                            Navigator.push(
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
            Divider(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'ติดต่อ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'สแกน QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR โค้ด',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'ตั้งค่า',
          ),
        ],
        currentIndex: 4,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/contact');
              break;
            case 2:
              context.go('/scan_qr');
              break;
            case 3:
              context.go('/qr_code');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
      ),
    );
  }
}