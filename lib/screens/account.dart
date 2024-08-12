import 'package:app_card/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_card/login_provider.dart';
import 'package:app_card/models/user.dart';
import 'package:app_card/screens/channgePass.dart';
import 'package:app_card/screens/editAccount.dart';
import 'package:app_card/services/users.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Future<User>? _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserData();
  }

  Future<User> _fetchUserData() async {
    final userId = Provider.of<LoginProvider>(context, listen: false).login?.id;
    return await UserService().getUserByid(userId!);
  }

  void _refreshUserData() {
    setState(() {
      _userFuture = _fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('บัญชี'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('บัญชี'),
            ),
            body: Center(
              child: Text('ข้อผิดพลาด: ${snapshot.error}'),
            ),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('บัญชี'),
            ),
            body: Center(
              child: Text('ไม่พบข้อมูลบัญชี'),
            ),
          );
        } else {
          final user = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('บัญชี'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text('${user.firstname} ${user.lastname}'),
                    subtitle: Text(user.email),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('แก้ไขรายละเอียดบัญชี'),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAccountScreen(user: user),
                        ),
                      );
                      if (result == true) {
                        _refreshUserData();
                      }
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('เปลี่ยนรหัสผ่าน'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangePasswordScreen()),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('ออกจากระบบ'),
                    onTap: () {
                      // แสดงกล่องโต้ตอบยืนยันก่อนออกจากระบบ
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('ออกจากระบบ'),
                            content: Text('คุณแน่ใจหรือไม่ที่จะออกจากระบบ?'),
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
                                  // ลงชื่อออกที่นี่
                                  Provider.of<LoginProvider>(context,
                                          listen: false)
                                      .logout();

                                  // นำทางไปยังหน้าลงชื่อเข้าใช้
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(),
                                    ),
                                    (Route<dynamic> route) => false,
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
          );
        }
      },
    );
  }
}
