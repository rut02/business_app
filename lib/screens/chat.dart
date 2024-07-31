import 'package:app_card/login_provider.dart';
import 'package:app_card/screens/chat_detail.dart';
import 'package:app_card/services/friends.dart';
import 'package:app_card/services/requests.dart';
import 'package:app_card/services/users.dart';
import 'package:flutter/material.dart';
import 'package:app_card/models/friend.dart';
import 'package:app_card/models/user.dart';
import 'package:provider/provider.dart';


class ChatScreen extends StatefulWidget {
  ChatScreen();

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<List<Friend>> friendsFuture;
  // late RequestServices requestService;
  late FriendService friendService;
  late UserService userService;

  @override
  void initState() {
    super.initState();
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    String userId = loginProvider.login!.id;
    // requestService = RequestServices();
    friendService = FriendService();
    userService = UserService();
    friendsFuture = friendService.getFriendByuserId(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: FutureBuilder<List<Friend>>(
        future: friendsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No friends found'));
          } else {
            List<Friend> friends = snapshot.data!;
            return ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                String friendId = friends[index].FriendsId;
                return FutureBuilder<User>(
                  future: userService.getUserByid(friendId),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text('Loading...'),
                      );
                    } else if (userSnapshot.hasError) {
                      return ListTile(
                        title: Text('Error: ${userSnapshot.error}'),
                      );
                    } else if (!userSnapshot.hasData) {
                      return ListTile(
                        title: Text('No user data found'),
                      );
                    } else {
                      User friend = userSnapshot.data!;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(friend.profile), // Assuming friend.profile contains URL of the profile picture
                        ),
                        title: Text('${friend.firstname} ${friend.lastname}'),
                        subtitle: Text('Last message...'), // You can replace this with the actual last message
                        trailing: Text('12:00 PM'), // You can replace this with the actual time of the last message
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(friend: friend),
                            ),
                          );
                        },
                      );
                    }
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
