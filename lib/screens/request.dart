//request.dart
import 'package:flutter/material.dart';
import 'package:app_card/models/status.dart';
import 'package:app_card/services/requests.dart';
import 'package:app_card/services/users.dart';
import 'package:provider/provider.dart';
import 'package:app_card/login_provider.dart';

class UserProfileScreen extends StatefulWidget {
  final String contactId;

  UserProfileScreen({required this.contactId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late String contactName;
  Status? status;

  final UserService userService = UserService();
  final RequestServices requestsService = RequestServices();

  @override
  void initState() {
    super.initState();
    loadContact();
  }

  void loadContact() async {
    try {
      var snapshot = await userService.getUserByid(widget.contactId);

      if (snapshot != null) {
        setState(() {
          contactName = snapshot.firstname + " " + snapshot.lastname;
        });
      } else {
        setState(() {
          contactName = 'ไม่พบผู้ใช้';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<Status> checkRequestStatus(String userId) async {
    try {
      return await requestsService.checkRequest(userId, widget.contactId);
    } catch (e) {
      throw Exception('Error checking request status: $e');
    }
  }

  Future<void> addRequest(String userId) async {
    try {
      await requestsService.add_request(userId, widget.contactId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request added successfully!'),
        ),
      );
      setState(() {});
    } catch (e) {
      print('Error adding request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16),
            FutureBuilder<Status>(
              future: checkRequestStatus(loginProvider.login!.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error loading data: ${snapshot.error}');
                } else {
                  status = snapshot.data;

                  return Column(
                    children: [
                      Text('Username: $contactName'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: status?.status == true
                            ? null
                            : () {
                                if (status != null) {
                                  addRequest(loginProvider.login!.id);
                                  userService.sendNotification(widget.contactId, "มีคำขอใหม่", "contactName");
                                  print("object");
                                  print(widget.contactId);
                                } else {
                                  print('Status not set');
                                }
                              },
                        child: Text(status?.status == true ? 'Request Sent' : 'Add Contact'),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
