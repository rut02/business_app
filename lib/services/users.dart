import 'dart:convert';
import 'dart:ui';
import 'package:app_card/models/create.dart';
import 'package:app_card/models/login.dart';
import 'package:app_card/models/profileImage.dart';
import 'package:app_card/models/request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:app_card/main.dart';
import 'package:app_card/models/user.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  Future<void> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> clearUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  Future<Create> createUser({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    required String phone,
    required String gender,
    required DateTime birthdate,
    required String subdistrict,
    required String district,
    required String province,
    required String country,
    required String position,
  }) async {
    try {
      final apiUrl = Uri.parse(api + '/users');
      final response = await http.post(
        apiUrl,
        body: json.encode({
          'email': email,
          'password': password,
          'firstname': firstname,
          'lastname': lastname,
          'phone': phone,
          'gender': gender,
          'birthdate': DateFormat('yyyy-MM-dd').format(birthdate),
          'country': country,
          'district': district,
          'province': province,
          'subdistrict': subdistrict,
          'position': position,
          'positionTemplate': "default",
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print(response.statusCode);
      print("from createUser");

      if (response.statusCode == 200) {
        print('User created successfully');
        final Map<String, dynamic> data = json.decode(response.body);
        print(data);
        return Create.fromJson(data);
      } else {
        print('Failed to create user. Status code: ${response.statusCode}');
        return Create();
      }
    } catch (e) {
      print("Error creating user: $e");
      return Create();
    }
  }

  Future<Login> authenticateUser(String email, String password) async {
    final apiUrl = Uri.parse(api + '/login');

    try {
      final response = await http.post(
        apiUrl,
        body: json.encode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Login.fromJson(data);
      } else {
        throw Exception(
            'Failed to authenticate user. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error authenticating user: $e");
      throw Exception('โปรดเชื่อมต่ออินเทอร์เน็ต');
    }
  }

Future<User> getUserByid(String uid) async {
  try {
    final apiUrl = Uri.parse(api + '/user/' + uid);
    final response = await http.get(apiUrl);
    print(response.statusCode);
    print("from users.dart");
    print(uid);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);

      if (data != null) {
        return User.fromJson(data);
      } else {
        print('ไม่สามารถแปลงข้อมูลที่ได้รับมาได้');
        return User();
      }
    } else {
      print('ไม่สามารถดึงข้อมูลผู้ใช้ได้. รหัสสถานะ: ${response.statusCode}');
      return User();
    }
  } catch (e) {
    print("ข้อผิดพลาดในการดึงข้อมูลผู้ใช้: $e");
    return User();
  }
}

  Future<ProfileImage> uploadProfileImage(
      String uid, String folder, String imagePath) async {
    try {
      final apiUrl =
          Uri.parse('https://business-api-638w.onrender.com/upload-image');
      var request = http.MultipartRequest('POST', apiUrl);

      // Add fields to the request
      request.fields['uid'] = uid;
      request.fields['folder'] = folder;

      // Read the file
      var imageFile = File(imagePath);
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();

      // Prepare the multipart file
      var multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: imagePath.split('/').last, // Extract file name from the path
        contentType: MediaType('image', 'jpeg'),
      );

      // Add the file to the request
      request.files.add(multipartFile);

      // Send the request
      var response = await request.send();

      // Check the response status
      if (response.statusCode == 200) {
        print('Profile image uploaded successfully');

        // Parse the response body
        var responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = json.decode(responseBody);

        print(data);

        // Return the Profile object
        return ProfileImage.fromJson(data);
      } else {
        print(
            'Failed to upload profile image. Status code: ${response.statusCode}');
        return ProfileImage();
      }
    } catch (e) {
      print("Error uploading profile image: $e");
      return ProfileImage();
    }
  }

  Future<void> create_card(String uid) async {
    try {
      final apiUrl =
          Uri.parse('https://business-api-638w.onrender.com/gen_card');
      final response = await http.post(
        apiUrl,
        body: json.encode({
          'uid': uid,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print("status ${response}");
      if (response.statusCode == 200) {
        print('Card created successfully');
      } else {
        print('Failed to create card. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error creating card: $e");
    }
  }
  
  Future<void> saveTokenToServer(String userId, String token) async {
    final apiUrl =
        Uri.parse('https://business-api-638w.onrender.com/user/token');
    final response = await http.post(
      apiUrl,
      body: json.encode({'userId': userId, 'token': token}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Token saved successfully');
    } else {
      print('Failed to save token. Status code: ${response.statusCode}');
    }
  }

  Future<void> sendNotification(String uid, String title, String body) async {
    try {
      final apiUrl =
          Uri.parse('https://business-api-638w.onrender.com/notifications');

      final response = await http.post(
        apiUrl,
        body: json.encode(
            {'userId': uid, 'messageTitle': title, 'messageBody': body}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print(
            'Failed to send notification. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
  Future<void> updateUser({
    required String uid,
    required String firstname,
    required String lastname,
    required String gender,
    required DateTime birthdate,
    required String phone,
    required String subdistrict,
    required String district,
    required String province,
    required String country,
    required String position,

  }) async {
    try {
      final apiUrl = Uri.parse(api + '/users/update/' + uid);
      final response = await http.put(
        apiUrl,
        body: json.encode({
          'firstname': firstname,
          'lastname': lastname,
          'gender': gender,
          'birthdate': DateFormat('yyyy-MM-dd').format(birthdate),
          'phone': phone,
          'country': country,
          'district': district,
          'province': province,
          'subdistrict': subdistrict,
          'position': position,
          'address': '$subdistrict, $district, $province, $country',
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('User updated successfully');
        await create_card(uid);
      } else {
        print('Failed to update user. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  Future<void> changePassword(String uid, String oldPassword, String newPassword) async {
    try {
      final apiUrl = Uri.parse(api + '/users/changepass/$uid/password');
      final response = await http.put(
        apiUrl,
        body: json.encode({'oldPassword': oldPassword, 'newPassword': newPassword}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Password updated successfully');
      } else {
        print('Failed to update password. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error updating password: $e");
    }
  }
  Future<bool> checkEmail(String email) async {
    try {
      final apiUrl = Uri.parse(api + '/users/check-email');
      final response = await http.post(
        apiUrl,
        body: json.encode({'email': email}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
            return true;
      } else {
        print('Failed to check email. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print("Error checking email: $e");
      return false;
    }
  }
}
