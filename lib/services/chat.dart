import 'dart:async';
import 'package:app_card/main.dart';
import 'package:app_card/models/message.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  final String API = api; // เปลี่ยน URL ให้ตรงกับ API ของคุณ
  final StreamController<List<Message>> _messagesController = StreamController<List<Message>>.broadcast();
  late WebSocketChannel _channel;
  List<Message> _allMessages = []; // เพิ่มตัวแปรนี้

  Stream<List<Message>> get messagesStream => _messagesController.stream;

  void connect() {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://business-api-638w.onrender.com'), // แก้ไข URL ของ WebSocket
    );
    _channel.stream.listen((message) {
      _handleIncomingMessage(message);
    });
    print('Connected to WebSocket');
  }

  void _handleIncomingMessage(String message) {
    print('Received message: $message'); // เพิ่ม log
    final data = jsonDecode(message);
    if (data['type'] == 'newMessage') {
      final newMessage = Message.fromJson(data['message']);
      _addMessage(newMessage); // เรียกใช้ฟังก์ชันนี้
    }
  }

  void _addMessage(Message message) {
    _allMessages.add(message);
    _allMessages.sort((a, b) => a.dateTime.compareTo(b.dateTime)); // เปลี่ยน DateTime เป็น dateTime
    _messagesController.add(_allMessages);
    print('Message added, total messages: ${_allMessages.length}'); // เพิ่ม log
  }

  Future<void> fetchMessages(String userId, String friendId) async {
    try {
      List<Message> sentMessages = await getMessageBySender(userId, friendId);
      List<Message> receivedMessages = await getMessageByReceiver(userId, friendId);
      _allMessages = [...sentMessages, ...receivedMessages];
      _allMessages.sort((a, b) => a.dateTime.compareTo(b.dateTime)); // เปลี่ยน DateTime เป็น dateTime
      _messagesController.add(_allMessages);
      print('Fetched messages, total messages: ${_allMessages.length}'); // เพิ่ม log
    } catch (e) {
      _messagesController.addError(e);
      print('Error fetching messages: $e'); // เพิ่ม log
    }
  }

  Future<List<Message>> getMessageBySender(String userId, String friendId) async {
    try {
      final response = await http.get(Uri.parse('$API/messages/sender/$userId/$friendId'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.isEmpty ? [] : data.map((message) => Message.fromJson(message)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  Future<List<Message>> getMessageByReceiver(String userId, String friendId) async {
    try {
      final response = await http.get(Uri.parse('$API/messages/receiver/$userId/$friendId'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.isEmpty ? [] : data.map((message) => Message.fromJson(message)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  Future<void> createMessage(String senderId, String receiverId, String messageContent) async {
    try {
      final messageData = {
        'senderId': senderId,
        'receiverId': receiverId,
        'messageContent': messageContent,
        'dateTime': DateTime.now().toIso8601String(), // เปลี่ยน DateTime เป็น dateTime
        'type': 'createMessage'
      };
      _channel.sink.add(json.encode(messageData));
      print('Message created and sent: $messageContent'); // เพิ่ม log
    } catch (e) {
      print('Failed to create message: $e'); // เพิ่ม log
    }
  }
  Future<Message?> fetchAndGetLastMessage(String userId, String friendId) async {
  try {
    // ดึงข้อความทั้งหมด
    await fetchMessages(userId, friendId);

    // ตรวจสอบว่ามีข้อความใน _allMessages หรือไม่
    if (_allMessages.isNotEmpty) {
      // คืนค่าข้อความล่าสุด (ข้อความที่มีวันที่และเวลาล่าสุด)
      return _allMessages.last;
    }
  } catch (e) {
    print('Error fetching or getting last message: $e');
  }

  return null; // ถ้าไม่มีข้อความหรือเกิดข้อผิดพลาด
}


  void disconnect() {
    _channel.sink.close();
    _messagesController.close();
    print('Disconnected from WebSocket');
  }
}
