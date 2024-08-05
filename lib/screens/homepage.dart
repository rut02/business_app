import 'package:app_card/login_provider.dart';
import 'package:app_card/services/notification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_card/models/user.dart';
import 'package:app_card/services/users.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.initNotification(context);
    // _notificationService.initPushNotification();
  }

  Future<User> _fetchUserDetails(BuildContext context) async {
    final loginResult = Provider.of<LoginProvider>(context, listen: false).login!;
    return await UserService().getUserByid(loginResult.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable the arrow back button
        title: const Text('HOME PAGE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.pushNamed(context, '/chat');
            },
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
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data != null) {
              final user = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const Text(
                      'MY CARD',
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
                                  'No Business Card Available',
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
                      'CARD DETAILS',
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
                              title: Text('AGE: ${user.age}'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: Text('GENDER: ${user.gender}'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.phone),
                              title: Text('TEL: ${user.phone}'),
                            ),
                            if (user.companybranch?.company.name != null)
                              ListTile(
                                leading: const Icon(Icons.business),
                                title: Text('Company: ${user.companybranch?.company.name}'),
                              ),
                            if (user.companybranch?.name != null)
                              ListTile(
                                leading: const Icon(Icons.location_city),
                                title: Text('Branch: ${user.companybranch?.name}'),
                              ),
                            if (user.department?.name != null)
                              ListTile(
                                leading: const Icon(Icons.apartment),
                                title: Text('Department: ${user.department?.name}'),
                              ),
                            if (user.department?.phone != null)
                              ListTile(
                                leading: const Icon(Icons.phone_in_talk),
                                title: Text('Department Phone: ${user.department?.phone}'),
                              ),
                            ListTile(
                              leading: const Icon(Icons.work),
                              title: Text('POSITION: ${user.position}'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.email),
                              title: Text('EMAIL: ${user.email}'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.location_on),
                              title: Text('ADDRESS: ${user.address}'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'CONTACT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'SCAN QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR CODE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'SETTINGS',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/contact');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/scan_qr');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/qr_code');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}