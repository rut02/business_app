import 'package:app_card/models/join.dart';
import 'package:app_card/services/friends.dart';
import 'package:app_card/services/group.dart';
import 'package:app_card/services/users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_card/models/friend.dart';
import 'package:app_card/models/user.dart';
import 'package:app_card/login_provider.dart';

class AddFriendsToGroupScreen extends StatefulWidget {
  final String groupId;

  AddFriendsToGroupScreen({required this.groupId});

  @override
  _AddFriendsToGroupScreenState createState() => _AddFriendsToGroupScreenState();
}

class _AddFriendsToGroupScreenState extends State<AddFriendsToGroupScreen> {
  final GroupService groupService = GroupService();
  final UserService userService = UserService();
  final FriendService friendService = FriendService();
  List<User> friends = [];
  List<User> groupMembers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFriends();
  }

  Future<void> loadFriends() async {
    final loginProvider = context.read<LoginProvider>();
    String? userId = loginProvider.login?.id;

    if (userId != null) {
      try {
        // Load group members
        List<User> members = [];
        List<Join> joins = await groupService.getUserByGroupId(widget.groupId);
        for (var join in joins) {
          User user = await userService.getUserByid(join.userId);
          members.add(user);
        }
        setState(() {
          groupMembers = members;
        });

        // Load friends
        List<Friend> friendList = await friendService.getFriendByuserId(userId);
        List<User> friendDetails = [];
        for (var friend in friendList) {
          User user = await userService.getUserByid(friend.userId);
          friendDetails.add(user);
        }

        // Filter friends who are already in the group
        List<User> filteredFriends = friendDetails.where((friend) {
          return !groupMembers.any((member) => member.id == friend.id);
        }).toList();

        setState(() {
          friends = filteredFriends;
          isLoading = false;
        });
      } catch (e) {
        print("Error loading friends: $e");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('User ID is null');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มเพื่อนในกลุ่ม'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                var friend = friends[index];
                return ListTile(
                  title: Text(friend.firstname),
                  subtitle: Text(friend.email),
                  leading: Icon(Icons.person),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      groupService.joinGroup(widget.groupId, friend.id);
                      Navigator.pop(context, friend);
                    },
                  ),
                );
              },
            ),
    );
  }
}
