import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_card/main.dart';
import 'package:app_card/models/friend.dart';

class FriendService {
  Future<void> createFriend(String userId, String friendsId) async {
    try {
      final apiUrl = Uri.parse(api + '/friends');
      final response = await http.post(
        apiUrl,
        body: json.encode({
          "userId": userId,
          "friendId": friendsId,
          "status": "0",
        }),
        headers: {'Content-Type': 'application/json'},
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        print('เพิ่มเพื่อนเรียบร้อยแล้ว');
      } else {
        print('ไม่สามารถเพิ่มเพื่อนได้. รหัสสถานะ: ${response.statusCode}');
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการเพิ่มเพื่อน: $e");
    }
  }
  Future<List<Friend>> getFriendByuserId(String userId) async {
    try {
      final apiUrl = Uri.parse(api + '/friends/by-user/' + userId);
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
  Future<void> updateFriendStatus(String userId, String friendId, String status) async {
    try {
      final apiUrl = Uri.parse(api + '/friends/status/' + userId + '/' + friendId );
      final response = await http.put(apiUrl,
      body: json.encode({
          "status": status,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('อัปเดตสถานะเพื่อนเรียบร้อยแล้ว');
      } else {
        print('ไม่สามารถอัปเดตสถานะเพื่อนได้. รหัสสถานะ: ${response.statusCode}');
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการอัปเดตสถานะเพื่อน: $e");
    }
  }
  Future<void> deleteFriend( String userId,String friendId) async {
    try {
      final apiUrl = Uri.parse(api + '/friends/all/' + userId + '/' + friendId);
      final response = await http.delete(apiUrl);

      if (response.statusCode == 200) {
        print('ลบเพื่อนเรียบร้อยแล้ว');
      } else {
        print('ไม่สามารถลบเพื่อนได้. รหัสสถานะ: ${response.statusCode}');
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการลบเพื่อน: $e");
    }
  }


}
