import 'package:app_card/login_provider.dart';
import 'package:app_card/main.dart';
import 'package:app_card/models/login.dart';
import 'package:app_card/services/users.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final UserService userService = UserService();

  bool isLoading = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'WELCOME TO BUSINESS CARD APP',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : () {},
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 20),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      final String email = emailController.text.trim();
                      final String password = passwordController.text.trim();

                      if (!isValidEmail(email)) {
                        setState(() {
                          errorMessage = 'รูปแบบอีเมลไม่ถูกต้อง';
                        });
                        return;
                      }

                      if (!isValidPassword(password)) {
                        setState(() {
                          errorMessage = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                        });
                        return;
                      }

                      setState(() {
                        isLoading = true;
                        errorMessage = '';
                      });

                      try {
                        final Login result = await userService.authenticateUser(email, password);

                        if (result.role == "hr" || result.role == "user") {
                          Provider.of<LoginProvider>(context, listen: false).setLogin(result);

                          // บันทึกข้อมูลลง SharedPreferences
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('loginData', jsonEncode(result.toJson()));
                          
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          setState(() {
                            errorMessage = 'เข้าสู่ระบบไม่สำเร็จ: บทบาทไม่ถูกต้อง';
                          });
                        }
                      } catch (error) {
                        setState(() {
                          errorMessage = 'เข้าสู่ระบบไม่สำเร็จ: ${error.toString()}';
                        });

                        // Check for 401 status code specifically
                        if (error.toString().contains('401')) {
                          setState(() {
                            errorMessage = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
                          });
                        }
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?'),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.pushReplacementNamed(context, '/register');
                            },
                      child: const Text('Create account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }
}
