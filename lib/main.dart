import 'package:app_card/screens/request.dart';
import 'package:app_card/services/notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';

import 'login_provider.dart';
import 'models/login.dart';
import 'services/users.dart';
import 'screens/homepage.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/contact.dart';
import 'screens/notification.dart';
import 'screens/qrcode.dart';
import 'screens/scanqr.dart';
import 'screens/setting.dart';
import 'screens/chat.dart';
import 'screens/group.dart';
import 'screens/history.dart';

final api = "https://business-api-638w.onrender.com";
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.notification?.body}");
  // ทำสิ่งที่คุณต้องการที่นี่ เช่น แสดงการแจ้งเตือนในพื้นหลัง
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  SharedPreferences prefs;
  Login? login;
  try {
    prefs = await SharedPreferences.getInstance();
    String? loginData = prefs.getString('loginData');
    if (loginData != null) {
      final Map<String, dynamic> loginMap = jsonDecode(loginData);
      login = Login.fromJson(loginMap);
    }
  } catch (e) {
    print("Error retrieving login data: $e");
  }

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(BusinessCardApp(login: login));
}
class BusinessCardApp extends StatelessWidget {
  final Login? login;

  BusinessCardApp({Key? key, this.login}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              login != null ? HomePage() : LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => HomePage(),
        ),
        GoRoute(
          path: '/contact',
          builder: (context, state) => ContactScreen(),
        ),
        GoRoute(
          path: '/scan_qr',
          builder: (context, state) => ScanQRScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => NotificationsScreen(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => ChatScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => SettingsScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => RegisterScreen(),
        ),
        GoRoute(
          path: '/group',
          builder: (context, state) => GroupScreen(),
        ),
        GoRoute(
          path: '/qr_code',
          builder: (context, state) => QRCodeScreen(),
        ),
        GoRoute(
          path: '/request/:userId',
          builder: (context, state) {
            final String userId = state.pathParameters['userId']!;
            return UserProfileScreen(contactId: userId);
          },
        ),
      ],
    );

    return ChangeNotifierProvider(
      create: (_) => LoginProvider()..setLogin(login),
      child: Consumer<LoginProvider>(
        builder: (context, loginProvider, _) {
          // Initialize notification service
          final notificationService = NotificationService();
          notificationService.initNotification(context);

          return MaterialApp.router(
            title: 'Business Card App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Roboto',
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}