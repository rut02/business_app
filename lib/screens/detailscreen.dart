import 'package:app_card/login_provider.dart';
import 'package:app_card/models/friend.dart';
import 'package:app_card/services/friends.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_card/models/user.dart';
import 'package:app_card/services/users.dart';

class DetailPage extends StatelessWidget {
  final String userId;

  const DetailPage({Key? key, required this.userId}) : super(key: key);

  Future<User> _fetchUserDetails(BuildContext context) async {
    return await UserService().getUserByid(userId);
  }

  Future<void> _deleteFriend(BuildContext context) async {
    try {
      final loginProvider = context.read<LoginProvider>();
      String? loggedInUserId = loginProvider.login?.id;
      if (loggedInUserId == null) {
        throw Exception('ผู้ใช้ยังไม่ได้เข้าสู่ระบบ');
      }
      await FriendService().deleteFriend(loggedInUserId, userId);
      if (context.mounted) {
        print('ลบผู้ใช้เรียบร้อยแล้ว');
        Navigator.of(context).pop();
        Navigator.pop(context, true); // ส่งข้อมูลกลับไปยังหน้า Contact
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('เกิดข้อผิดพลาดในการลบผู้ใช้: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้ารายละเอียด'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'delete') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('ยืนยันการลบ'),
                      content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบผู้ใช้นี้?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('ยกเลิก'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('ลบ'),
                          onPressed: () {
                            _deleteFriend(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('ลบ'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<User>(
          future: _fetchUserDetails(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data != null) {
              final user = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const Text(
                      'รายละเอียดผู้ใช้',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: user.business_card.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(user.business_card),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: user.business_card.isEmpty
                            ? const Center(
                                child: Text(
                                  'ไม่มีบัตรธุรกิจ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'รายละเอียดบัตร',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: Text('${user.firstname} ${user.lastname}'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: Text('อายุ: ${user.age}'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: Text('เพศ: ${user.gender}'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.phone),
                              title: Text('เบอร์โทร: ${user.phone}'),
                            ),
                            if (user.companybranch?.company.name != null)
                              ListTile(
                                leading: const Icon(Icons.business),
                                title: Text(
                                    'บริษัท: ${user.companybranch?.company.name}'),
                              ),
                            if (user.companybranch?.name != null)
                              ListTile(
                                leading: const Icon(Icons.location_city),
                                title: Text(
                                    'สาขา: ${user.companybranch?.name}'),
                              ),
                            if (user.department?.name != null)
                              ListTile(
                                leading: const Icon(Icons.apartment),
                                title: Text(
                                    'แผนก: ${user.department?.name}'),
                              ),
                            if (user.department?.phone != null)
                              ListTile(
                                leading: const Icon(Icons.phone_in_talk),
                                title: Text(
                                    'เบอร์โทรแผนก: ${user.department?.phone}'),
                              ),
                            ListTile(
                              leading: const Icon(Icons.work),
                              title: Text('ตำแหน่ง: ${user.position}'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.email),
                              title: Text('อีเมล: ${user.email}'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.location_on),
                              title: Text('ที่อยู่: ${user.address}'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('ไม่มีข้อมูล'));
            }
          },
        ),
      ),
    );
  }
}
