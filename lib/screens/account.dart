import 'dart:io';

import 'package:app_card/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_card/login_provider.dart';
import 'package:app_card/models/user.dart';
import 'package:app_card/screens/channgePass.dart';
import 'package:app_card/screens/editAccount.dart';
import 'package:app_card/services/users.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Future<User>? _userFuture;
  final ImagePicker _picker = ImagePicker();

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

  // Future<void> _showChangeProfileImageDialog() async {
  //   final userId = Provider.of<LoginProvider>(context, listen: false).login?.id;
  //   final image = await _picker.pickImage(source: ImageSource.gallery);

  //   if (image != null && userId != null) {
  //     final result = await UserService().uploadProfileImage(userId, 'profile', image.path);
  //     if (result != null) {
  //       _refreshUserData();
  //     }
  //   }
  // }

  
  void _showChangeProfileImageDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('เปลี่ยนรูปโปรไฟล์'),
        content: Text('คุณต้องการเปลี่ยนรูปโปรไฟล์หรือไม่?'),
        actions: <Widget>[
          TextButton(
            child: Text('ยกเลิก'),
            onPressed: () {
              Navigator.of(context).pop(); // ปิดกล่องโต้ตอบ
            },
          ),
          TextButton(
            child: Text('เลือกจากแกลเลอรี่'),
            onPressed: () async {
              Navigator.of(context).pop(); // ปิดกล่องโต้ตอบ
              final userId = Provider.of<LoginProvider>(context, listen: false).login?.id;
              final image = await _picker.pickImage(source: ImageSource.gallery);

              if (image != null && userId != null) {
                final result = await UserService().uploadProfileImage(userId, 'profile', image.path);
                if (result != null) {
                  _refreshUserData();
                }
              }
            },
          ),
        ],
      );
    },
  );
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
                  leading: GestureDetector(
                    onTap: _showChangeProfileImageDialog,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: user.profile.isNotEmpty
                          ? NetworkImage(user.profile)
                          : null,
                      child: user.profile.isEmpty
                          ? Icon(Icons.account_circle, size: 30)
                          : null,
                    ),
                  ),
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
                                Provider.of<LoginProvider>(context,
                                        listen: false)
                                    .logout();
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
