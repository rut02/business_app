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
      await FriendService().deleteFriend(loggedInUserId!, userId);
      if (context.mounted) {
        print('User deleted successfully');
        Navigator.pop(context); // กลับไปหน้าก่อนหน้าเมื่อการลบเสร็จสิ้น
      }
    } catch (e) {
      // Handle delete error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error deleting user: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DETAIL PAGE'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'delete') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: const Text('Are you sure you want to delete this user?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Delete'),
                          onPressed: () {
                            Navigator.of(context).pop();
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
                child: Text('Delete'),
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
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data != null) {
              final user = snapshot.data!;
              return ListView(
                children: <Widget>[
                  const Text(
                    'USER DETAILS',
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
                            title: Text('BIRTH-DAY: ${user.birthdate}'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text('GENDER: ${user.gender}'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.phone),
                            title: Text('TEL: ${user.phone}'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.work),
                            title: Text('POSITION: ${user.position}'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: Text('EMAIL: ${user.email}'),
                          ),
                          if (user.companybranch != null)
                            ListTile(
                              leading: const Icon(Icons.location_city),
                              title: Text('COMPANY BRANCH: ${user.companybranch}'),
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
              );
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }
}
