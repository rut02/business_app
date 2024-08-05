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

  Future<List<User>> loadFriends() async {
    final loginProvider = context.read<LoginProvider>();
    String? userId = loginProvider.login?.id;

    if (userId == null) {
      throw Exception('User ID เป็น null');
    }

    // โหลดสมาชิกกลุ่ม
    List<User> members = [];
    List<Join> joins = await groupService.getUserByGroupId(widget.groupId);
    for (var join in joins) {
      User user = await userService.getUserByid(join.userId);
      members.add(user);
    }

    // โหลดเพื่อน
    List<Friend> friendList = await friendService.getFriendByuserId(userId);
    List<User> friendDetails = [];
    for (var friend in friendList) {
      User user = await userService.getUserByid(friend.friendId);
      friendDetails.add(user);
    }

    // กรองเพื่อนที่อยู่ในกลุ่มแล้ว
    List<User> filteredFriends = friendDetails.where((friend) {
      return !members.any((member) => member.id == friend.id);
    }).toList();

    return filteredFriends;
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
      body: FutureBuilder<List<User>>(
        future: loadFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('ข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('ไม่มีเพื่อนที่จะเพิ่ม'));
          } else {
            List<User> friends = snapshot.data!;
            return ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                var friend = friends[index];
                return ListTile(
                  title: Text(friend.firstname),
                  subtitle: Text(friend.email),
                  leading: Icon(Icons.person),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () async {
                      await groupService.joinGroup(widget.groupId, friend.id);
                      Navigator.pop(context, friend);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}