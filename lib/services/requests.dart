import 'package:app_card/main.dart';
import 'package:app_card/models/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestServices {
  Future<void> add_request(String requester, String responder) async {
    try {
      final apiUrl = Uri.parse('https://business-api-638w.onrender.com/requests');
      final response = await http.post(
        apiUrl,
        body: json.encode({
          'requesterId': requester,
          'responderId': responder,
          'status': '0'
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print("status ${response.statusCode}");
      if (response.statusCode == 200) {
        print('add request successfully');

        // ส่งการแจ้งเตือน
        await sendNotificationToUser(responder, 'New Request', 'You have received a new request.');
      } else {
        print('Failed to add request card. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error add request card: $e");
    }
  }

  Future<void> sendNotificationToUser(String userId, String title, String body) async {
    final token = await getUserToken(userId);  // ฟังก์ชันสำหรับดึง token ของผู้ใช้

    if (token != null) {
      final response = await http.post(
        Uri.parse('https://your-server-url/send-notification'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'token': token,
          'messageTitle': title,
          'messageBody': body,
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification');
      }
    } else {
      print('No token found for user');
    }
  }

  Future<String?> getUserToken(String userId) async {
    // ฟังก์ชันสำหรับดึง token ของผู้ใช้จากฐานข้อมูล
    try {
      final apiUrl = Uri.parse('https://your-server-url/users/$userId/token');
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['token'];
      } else {
        print('Failed to fetch user token. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print("Error fetching user token: $e");
      return null;
    }
  }
  Future<List<Request>> getRequestByrequester(String requester) async {
  try {
    final apiUrl = Uri.parse(api + '/requests/by-requester/' + requester);
    final response = await http.get(apiUrl);

    print(response.statusCode);
    print("from requests.dart");
    print(requester);
    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Request.fromJson(item)).toList();
    } else {
      print('Failed to fetch request data. Status code: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print("Error fetching request data: $e");
    return [];
  }
}


  Future<List<Request>> getRequestByresponder(String responder) async {
  try {
    final apiUrl = Uri.parse(api + '/requests/by-responder/' + responder);
    final response = await http.get(apiUrl);

    print(response.statusCode);
    print("from requests.dart");
    print(responder);
    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      
      // แปลง List<dynamic> เป็น List<Request>
      return data.map((item) => Request.fromJson(item)).toList();
    } else {
      print('Failed to fetch request data. Status code: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print("Error fetching request data: $e");
    return [];
  }
}


  Future<Request> getRequestById(String requestId) async {
    try {
      final apiUrl = Uri.parse(api + '/requests/' + requestId);
      final response = await http.get(apiUrl);
      print(response.statusCode);
      print("from requests.dart");
      print(requestId);
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);

        if (data != null) {
          return Request.fromJson(data);
        } else {
          print('Unable to parse received data.');
          return Request();
        }
      } else {
        print(
            'Failed to fetch request data. Status code: ${response.statusCode}');
        return Request();
      }
    } catch (e) {
      print("Error fetching request data: $e");
      return Request();
    }
  }
  Future<List<Friend>> getFriendByuserId(String userId) async {
    try {
      final apiUrl = Uri.parse(api + '/requests/friends/' + userId);
      final response = await http.get(apiUrl);

      print(response.statusCode);
      print("from friends.dart");
      print(userId);
      print(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Friend.fromJson(item)).toList();
      } else {
        print('Failed to fetch friend data. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print("Error fetching friend data: $e");
      return [];
    }
  }

  Future<Status> checkRequest(String requesterId, String responderId) async {
    try {
      print("chk request");
      final apiUrl = Uri.parse(api+'/requests/check/' + requesterId + '/' + responderId);
      final response = await http.get(apiUrl);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(response.body);
        return Status.fromJson(data);        
      }
      else {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Failed to fetch chk request. Status code: ${response.statusCode}');
        return Status.fromJson(data); 
      }
      
    } 
    catch (e) {
      print("Error checkRequesttt: $e");
      return Status();
    }   
  }
  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      final apiUrl = Uri.parse(api + '/requests/' + requestId);
      final response = await http.put(
        apiUrl,
        body: json.encode({'status': status}),
        headers: {'Content-Type': 'application/json'},
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('Request status updated successfully');
      } else {
        print('Failed to update request status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error updating request status: $e");
    }
  }

}
