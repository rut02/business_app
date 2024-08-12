import 'package:app_card/login_provider.dart';
import 'package:app_card/screens/chat_detail.dart';
import 'package:app_card/services/chat.dart';
import 'package:app_card/services/friends.dart';
import 'package:app_card/services/users.dart';
import 'package:flutter/material.dart';
import 'package:app_card/models/friend.dart';
import 'package:app_card/models/user.dart';
import 'package:app_card/models/message.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen();

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<List<Map<String, dynamic>>> friendsDataFuture;
  late FriendService friendService;
  late UserService userService;
  late ChatService chatService;
  late String userId;

  @override
  void initState() {
    super.initState();
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    userId = loginProvider.login!.id;
    friendService = FriendService();
    userService = UserService();
    chatService = ChatService();
    friendsDataFuture = _loadFriendsData();
  }

  Future<List<Map<String, dynamic>>> _loadFriendsData() async {
    List<Friend> friends = await friendService.getFriendByuserId(userId);
    List<Map<String, dynamic>> friendsData = [];

    for (Friend friend in friends) {
      User friendUser = await userService.getUserByid(friend.friendId);
      Message? lastMessage = await chatService.fetchAndGetLastMessage(userId, friend.friendId);
      friendsData.add({
        'friend': friendUser,
        'lastMessage': lastMessage,
      });
    }

    return friendsData;
  }

  String formatTimestamp(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;

    if (difference == 0) {
      return DateFormat('H:mm น.').format(dateTime);
    } else if (difference == 1) {
      return 'เมื่อวานนี้';
    } else {
      return DateFormat('d MMM, H:mm น.').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แชท'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: friendsDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('ข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('ไม่พบเพื่อน'));
          } else {
            List<Map<String, dynamic>> friendsData = snapshot.data!;
            return ListView.builder(
              itemCount: friendsData.length,
              itemBuilder: (context, index) {
                User friend = friendsData[index]['friend'];
                Message? lastMessage = friendsData[index]['lastMessage'];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friend.profile),
                    radius: 30,
                  ),
                  title: Text(
                    '${friend.firstname} ${friend.lastname}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: lastMessage != null
                      ? Text(
                          lastMessage.messageContent,
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          'ยังไม่มีข้อความ',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                  trailing: lastMessage != null
                      ? Text(
                          formatTimestamp(lastMessage.dateTime),
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(friend: friend),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
