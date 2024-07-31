import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

import 'package:go_router/go_router.dart';

final api = "https://business-api-638w.onrender.com";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final UserService userService = UserService();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? loginData = prefs.getString('loginData');
  Login? login;
  print('loginData: $loginData');
  if (loginData != null) {
    final Map<String, dynamic> loginMap = jsonDecode(loginData);
    login = Login.fromJson(loginMap);
  }

  runApp(BusinessCardApp(login: login));
}

class BusinessCardApp extends StatelessWidget {
  final Login? login;

  BusinessCardApp({Key? key, this.login}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => LoginScreen(),
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
          path: '/qr_code',
          builder: (context, state) => QRCodeScreen(),
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
        // GoRoute(
        //   path: '/history',
        //   builder: (context, state) => HistoryScreen(),
        // ),
      ],
      initialLocation: login != null ? '/home' : '/',
      debugLogDiagnostics: true,
    );

    return ChangeNotifierProvider(
      create: (_) => LoginProvider()..setLogin(login),
      child: MaterialApp.router(
        routerConfig: _router,
        title: 'Business Card App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    );
  }
}
 