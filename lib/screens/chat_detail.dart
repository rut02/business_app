import 'dart:async';
import 'package:app_card/services/chat.dart';
import 'package:flutter/material.dart';
import 'package:app_card/models/user.dart';
import 'package:app_card/models/message.dart';
import 'package:provider/provider.dart';
import 'package:app_card/login_provider.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  final User friend;

  ChatDetailScreen({required this.friend});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Stream<List<Message>> messagesStream;

  @override
  void initState() {
    super.initState();
    loadMessages();
    chatService.connect();
  }

  void loadMessages() {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    String userId = loginProvider.login!.id;
    messagesStream = chatService.messagesStream;
    chatService.fetchMessages(userId, widget.friend.id);
  }

  void sendMessage() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    String userId = loginProvider.login!.id;
    String messageContent = _messageController.text;

    if (messageContent.trim().isEmpty) {
      return;
    }

    try {
      await chatService.createMessage(userId, widget.friend.id, messageContent);
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print('Failed to send message: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;

    if (difference == 0) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  @override
  void dispose() {
    chatService.disconnect();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.friend.firstname} ${widget.friend.lastname}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No messages found'));
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  List<Message> messages = snapshot.data!;
                  final loginProvider = Provider.of<LoginProvider>(context, listen: false);
                  String userId = loginProvider.login!.id;
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      Message message = messages[index];
                      bool isSender = message.senderId == userId;
                      return Align(
                        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: isSender ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.messageContent,
                                style: TextStyle(color: isSender ? Colors.white : Colors.black),
                              ),
                              SizedBox(height: 5),
                              Text(
                                formatTimestamp(message.dateTime),
                                style: TextStyle(color: isSender ? Colors.white70 : Colors.black54, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
