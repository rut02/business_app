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
    return ChangeNotifierProvider(
      create: (_) => LoginProvider()..setLogin(login),
      child: Consumer<LoginProvider>(
        builder: (context, loginProvider, _) {
          return MaterialApp(
            title: 'Business Card App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => loginProvider.login != null ? HomePage() : LoginScreen(),
              '/home': (context) => HomePage(),
              '/contact': (context) => ContactScreen(),
              '/scan_qr': (context) => ScanQRScreen(),
              '/notifications': (context) => NotificationsScreen(),
              '/chat': (context) => ChatScreen(),
              '/settings': (context) => SettingsScreen(),
              '/register': (context) => RegisterScreen(),
              '/group': (context) => GroupScreen(),
              '/qr_code': (context) => QRCodeScreen(),
            },
          );
        },
      ),
    );
  }
}
