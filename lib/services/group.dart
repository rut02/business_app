import 'package:app_card/models/group.dart';
import 'package:app_card/models/join.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroupService {
  Future<void> createGroup(String name, String ownerId) async {
    try {
      final apiUrl = Uri.parse('https://business-api-638w.onrender.com/groups');
      final response = await http.post(
        apiUrl,
        body: json.encode({
          'name': name,
          'ownerId': ownerId,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        print('Group created successfully');
      } else {
        print('Failed to create group. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error creating group: $e");
    }
  }

  Future<void> joinGroup(String groupId, String userId) async {
    try {
      final apiUrl =
          Uri.parse('https://business-api-638w.onrender.com/joins');
      final response = await http.post(
        apiUrl,
        body: json.encode({
          'groupId': groupId,
          'userId': userId,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        print('Group joined successfully');
      } else {
        print('Failed to join group. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error joining group: $e");
    }
  }

  Future<List<Group>> getGroupByOwnerId(String userId) async {
    try {
      final apiUrl = Uri.parse(
          'https://business-api-638w.onrender.com/groups/by-owner/' + userId);
      final response = await http.get(apiUrl);
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Group.fromJson(item)).toList();
      } else {
        print(
            'Failed to fetch group data. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print("Error fetching group data: $e");
      return [];
    }
  }

  Future<void> joinMembers(String groupId, String userId) async {
    try {
      final apiUrl = Uri.parse('https://business-api-638w.onrender.com/joins');
      final response = await http.post(
        apiUrl,
        body: json.encode({
          'groupId': groupId,
          'userId': userId,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        print('Group joined successfully');
      } else {
        print('Failed to join group. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error joining group: $e");
    }
  }

  Future<List<Join>> getUserByGroupId(String groupId) async {
    try {
      final apiUrl = Uri.parse(
          'https://business-api-638w.onrender.com/joins/by-group/' + groupId);
      final response = await http.get(apiUrl);
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Join.fromJson(item)).toList();
      } else {
        print(
            'Failed to fetch group data. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print("Error fetching group data: $e");
      return [];
    }
  }

  Future<void> removeUserFromGroup(String groupId, String userId) async {
    try {
      final apiUrl = Uri.parse(
          'https://business-api-638w.onrender.com/joins/' + userId + '/' + groupId);
      final response = await http.delete(apiUrl);
      print(response.body);
      if (response.statusCode == 200) {
        print('User removed from group successfully');
      } else {
        print('Failed to remove user from group. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error removing user from group: $e");
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      final apiUrl = Uri.parse('https://business-api-638w.onrender.com/groups/' + groupId);
      final response = await http.delete(apiUrl);
      print(response.body);
      if (response.statusCode == 200) {
        print('Group deleted successfully');
      } else {
        print('Failed to delete group. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error deleting group: $e");
    }
  }
  Future<void> updateGroupName(String groupId, String name) async {
    try {
      final apiUrl = Uri.parse('https://business-api-638w.onrender.com/groups/' + groupId);
      final response = await http.put(
        apiUrl,
        body: json.encode({
          'name': name,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        print('Group updated successfully');
      } else {
        print('Failed to update group. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error updating group: $e");
    }
  }
 
}
