import 'package:app_card/models/user.dart';
import 'package:app_card/screens/channgePass.dart';
import 'package:app_card/screens/editAccount.dart';
import 'package:app_card/services/users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_card/login_provider.dart';

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
              title: Text('Account'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Account'),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Account'),
            ),
            body: Center(
              child: Text('No account data found'),
            ),
          );
        } else {
          final user = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Account'),
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
                    title: Text('Edit Account Details'),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditAccountScreen()),
                      );
                      if (result == true) {
                        _refreshUserData();
                      }
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('Change Password'),
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
                    title: Text('Logout'),
                    onTap: () {
                      Provider.of<LoginProvider>(context, listen: false)
                          .logout();
                      Navigator.pushReplacementNamed(context, '/');
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