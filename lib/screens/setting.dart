import 'package:app_card/login_provider.dart';
import 'package:app_card/screens/friendstatus.dart';
import 'package:app_card/screens/history.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<LoginProvider>(context, listen: false).login?.id;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Account'),
              onTap: () {
                // Handle account settings
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CombinedScreen(userId: userId!)),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Friend Stats'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendStatsScreen(userId: userId!)),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout), // Icon for logout
              title: Text('Logout'), // Text for logout
              onTap: () {
                // Logout logic here
                // Example: Clear user session, navigate to login screen

                // For example, if using Provider for user state management
                Provider.of<LoginProvider>(context, listen: false).logout();

                // Navigate to login screen
                Navigator.pushReplacementNamed(context, '/');
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
        currentIndex: 4,
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
              // No action needed when tapping on current tab (Settings)
              break;
          }
        },
      ),
    );
  }
}
