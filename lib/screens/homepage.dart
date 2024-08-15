import 'dart:async';
import 'package:app_card/screens/chat.dart';
import 'package:app_card/screens/notification.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_card/login_provider.dart';
import 'package:app_card/models/user.dart';
import 'package:app_card/services/users.dart';
import 'package:app_card/services/notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NotificationService _notificationService = NotificationService();
  late Future<User> _userFuture;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _notificationService.initNotification(context);
        // ตรวจสอบสถานะการเชื่อมต่อเมื่อเริ่มต้น
    _checkConnectivity();
    



    // ตรวจสอบการเปลี่ยนแปลงของสถานะการเชื่อมต่อ
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      setState(() {
        _isConnected = !result.contains(ConnectivityResult.none);
      });
    });
    _userFuture = _fetchUserDetails(context);
  }

  Future<void> _checkConnectivity() async {
    final List<ConnectivityResult> result = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = !result.contains(ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<User> _fetchUserDetails(BuildContext context) async {
    final loginResult =
        Provider.of<LoginProvider>(context, listen: false).login;

    if (loginResult?.id == null) {
      throw Exception('User ID is null');
    }

    try {
      User user = await UserService().getUserByid(loginResult!.id);

      if (user.business_card.isEmpty) {
        user.business_card = ''; // กำหนดค่าเริ่มต้นถ้ายังไม่ได้รับการกำหนดค่า
      }

      return user;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('loginData');
      Provider.of<LoginProvider>(context, listen: false).setLogin(null);
      context.go('/');
      rethrow;
    }
  }

  Widget _buildUserInfoListTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('หน้าหลัก'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isConnected
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<User>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: ${snapshot.error}'),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _userFuture = _fetchUserDetails(context);
                              });
                            },
                            child: const Text('ลองอีกครั้ง'),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    final user = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          const Text(
                            'บัตรของฉัน',
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
                                  _buildUserInfoListTile(Icons.person,
                                      '${user.firstname} ${user.lastname}'),
                                  _buildUserInfoListTile(
                                      Icons.phone, 'เบอร์โทร: ${user.phone}'),
                                  if (user.companybranch?.company.name != null)
                                    _buildUserInfoListTile(Icons.business,
                                        'บริษัท: ${user.companybranch?.company.name}'),
                                  if (user.companybranch?.name != null)
                                    _buildUserInfoListTile(Icons.location_city,
                                        'สาขา: ${user.companybranch?.name}'),
                                  if (user.department?.name != null)
                                    _buildUserInfoListTile(Icons.apartment,
                                        'แผนก: ${user.department?.name}'),
                                  if (user.department?.phone != null)
                                    _buildUserInfoListTile(Icons.phone_in_talk,
                                        'เบอร์แผนก: ${user.department?.phone}'),
                                  _buildUserInfoListTile(
                                      Icons.work, 'ตำแหน่ง: ${user.position}'),
                                       _buildUserInfoListTile(Icons.work, 'ตำแหน่ง: ${user.position}'),
                                  _buildUserInfoListTile(Icons.email, 'อีเมล: ${user.email}'),
                                  _buildUserInfoListTile(Icons.location_on, 'ที่อยู่: ${user.address}'),
                                  _buildUserInfoListTile(Icons.calendar_today, 'อายุ: ${user.age}'),
                                  _buildUserInfoListTile(Icons.person_outline, 'เพศ: ${user.gender}'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text('ไม่พบข้อมูลผู้ใช้'),
                    );
                  }
                },
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'คุณไม่ได้เชื่อมต่ออินเทอร์เน็ต',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _checkConnectivity();
                    },
                    child: const Text('ตรวจสอบการเชื่อมต่อ'),
                  ),
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
        currentIndex: 0,
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
