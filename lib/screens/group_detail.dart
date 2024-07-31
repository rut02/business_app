import 'package:app_card/models/join.dart';
import 'package:app_card/models/user.dart';
import 'package:app_card/screens/add_friend_to_group.dart';
import 'package:app_card/screens/detailscreen.dart';
import 'package:app_card/services/group.dart';
import 'package:app_card/services/users.dart';
import 'package:flutter/material.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  String groupName;

  GroupDetailScreen({required this.groupId, required this.groupName});

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupService groupService = GroupService();
  final UserService userService = UserService();
  List<User> users = [];
  bool isLoading = true;
  bool isDeleteMode = false;
  List<String> selectedUserIds = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      List<Join> joins = await groupService.getUserByGroupId(widget.groupId);
      List<User> userList = [];
      for (var join in joins) {
        User user = await userService.getUserByid(join.userId);
        userList.add(user);
      }
      setState(() {
        users = userList;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading users: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteUserFromGroup() async {
    try {
      for (var userId in selectedUserIds) {
        await groupService.removeUserFromGroup(widget.groupId, userId);
      }
      loadUsers(); // Reload the users list
      setState(() {
        selectedUserIds.clear();
        isDeleteMode = false;
      });
    } catch (e) {
      print("Error removing user from group: $e");
    }
  }

  void showEditGroupDialog() {
    final TextEditingController groupNameController = TextEditingController(text: widget.groupName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('แก้ไขชื่อกลุ่ม'),
          content: TextField(
            controller: groupNameController,
            decoration: InputDecoration(
              labelText: 'ชื่อกลุ่ม',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('บันทึก'),
              onPressed: () async {
                String groupName = groupNameController.text;
                if (groupName.isNotEmpty) {
                  await groupService.updateGroupName(widget.groupId, groupName);
                  setState(() {
                    widget.groupName = groupName;
                  });
                  Navigator.of(context).pop();
                } else {
                  print('Group name is empty');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        leading: IconButton(
          icon: Icon(isDeleteMode ? Icons.close : Icons.arrow_back),
          onPressed: () {
            if (isDeleteMode) {
              setState(() {
                isDeleteMode = false;
                selectedUserIds.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFriendsToGroupScreen(groupId: widget.groupId),
                ),
              ).then((value) => loadUsers()); // Reload users when returning from the add friends screen
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'edit') {
                showEditGroupDialog();
              } else if (value == 'delete') {
                setState(() {
                  isDeleteMode = true;
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('เปลี่ยนชื่อ'),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('ลบสมาชิก'),
                ),
              ];
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline, size: 100, color: Colors.grey),
                      Text('ไม่มีรายชื่อผู้ติดต่อ', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          var user = users[index];
                          bool isSelected = selectedUserIds.contains(user.id);
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.profile != null
                                  ? NetworkImage(user.profile!)
                                  : AssetImage('assets/default_profile.png') as ImageProvider,
                            ),
                            title: Text('${user.firstname} ${user.lastname}'),
                            subtitle: Text('อีเมล: ${user.email}\nตำแหน่ง: ${user.position}'),
                            trailing: isDeleteMode
                                ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedUserIds.remove(user.id);
                                        } else {
                                          selectedUserIds.add(user.id);
                                        }
                                      });
                                    },
                                    child: Icon(
                                      isSelected ? Icons.cancel : Icons.radio_button_unchecked,
                                      color: isSelected ? Colors.red : Colors.grey,
                                    ),
                                  )
                                : null,
                            onTap: () {
                              if (isDeleteMode) {
                                setState(() {
                                  if (isSelected) {
                                    selectedUserIds.remove(user.id);
                                  } else {
                                    selectedUserIds.add(user.id);
                                  }
                                });
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPage(userId: user.id),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                    if (isDeleteMode)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.delete),
                          label: Text('ลบผู้ใช้ที่เลือก'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: selectedUserIds.isNotEmpty ? Colors.red : Colors.grey,
                          ),
                          onPressed: selectedUserIds.isNotEmpty
                              ? () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('ลบผู้ใช้'),
                                        content: Text('คุณต้องการลบผู้ใช้ที่เลือกออกจากกลุ่มใช่หรือไม่?'),
                                        actions: [
                                          TextButton(
                                            child: Text('ยกเลิก'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('ลบ'),
                                            onPressed: () {
                                              deleteUserFromGroup();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              : null,
                        ),
                      ),
                  ],
                ),
    );
  }
}
