import 'package:app_card/login_provider.dart';
import 'package:app_card/screens/notification.dart';
import 'package:app_card/services/users.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final UserService userService = UserService();

  Future<void> initNotification(BuildContext context) async {
    await _firebaseMessaging.requestPermission();

    // รับ FCM token และเก็บใน Firestore
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print("token: $token");
    if (token != null) {
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      final userid = loginProvider.login?.id;
      if (userid != null) {
        await userService.saveTokenToServer(userid, token);
        print("update token success");
      } else {
        print("User ID is null");
      }
    }

    // Initialize flutter_local_notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => NotificationsScreen()),
          );
        }
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message while in the foreground: ${message.notification?.body}');
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      // _showNotification(message);
      print('Received message while in the background: ${message.notification?.body}');
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => NotificationsScreen()),
      );
    });

    // Handle when the app is opened from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        // _showNotification(message);
        print('App opened from terminated state!');
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => NotificationsScreen()),
        );
      }
    });
  }

  void handleNotification(RemoteMessage? message) {
    if (message == null) {
      return;
    }

    print("Message data: ${message.notification?.body}");
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your_channel_id', 'your_channel_name',
            importance: Importance.max, priority: Priority.high, showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        0, message.notification?.title, message.notification?.body, platformChannelSpecifics,
        payload: 'item x');  // ส่ง payload เพื่อบอกว่าให้ไปหน้าไหน
  }

  Future initPushNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(handleNotification);
  }
}