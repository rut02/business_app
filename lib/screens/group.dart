import 'package:app_card/models/join.dart';
import 'package:app_card/screens/group_detail.dart';
import 'package:app_card/services/group.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_card/login_provider.dart';
import 'package:app_card/models/group.dart';

class GroupScreen extends StatefulWidget {
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final GroupService groupService = GroupService();
  List<Group> groups = [];
  Map<String, int> groupUserCount = {};
  bool isLoading = true;
  bool isDeleteMode = false;
  List<String> selectedGroupIds = [];

  @override
  void initState() {
    super.initState();
    loadGroups();
  }

  Future<void> loadGroups() async {
    final loginProvider = context.read<LoginProvider>();
    String? userId = loginProvider.login?.id;

    if (userId != null) {
      try {
        List<Group> groupList = await groupService.getGroupByOwnerId(userId);
        for (var group in groupList) {
          List<Join> joins = await groupService.getUserByGroupId(group.id);
          groupUserCount[group.id] = joins.length;
        }
        setState(() {
          groups = groupList;
          isLoading = false;
        });
      } catch (e) {
        print("Error loading groups: $e");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('User ID is null');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showCreateGroupDialog() {
  final TextEditingController groupNameController = TextEditingController();
  final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);
  final loginProvider = context.read<LoginProvider>();
  String? userId = loginProvider.login?.id;

  groupNameController.addListener(() {
    isButtonEnabled.value = groupNameController.text.isNotEmpty;
  });

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('สร้างกลุ่มใหม่'),
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
          ValueListenableBuilder<bool>(
            valueListenable: isButtonEnabled,
            builder: (context, value, child) {
              return TextButton(
                child: Text('บันทึก'),
                onPressed: value
                    ? () async {
                        String groupName = groupNameController.text;
                        if (groupName.isNotEmpty && userId != null) {
                          await groupService.createGroup(groupName, userId);
                          Navigator.of(context).pop();
                          loadGroups(); // Reload the groups
                        } else {
                          print('Group name is empty or userId is null');
                        }
                      }
                    : null,
              );
            },
          ),
        ],
      );
    },
  );
}

  void deleteSelectedGroups() async {
    try {
      for (var groupId in selectedGroupIds) {
        await groupService.deleteGroup(groupId);
      }
      loadGroups(); // Reload the groups list
      setState(() {
        selectedGroupIds.clear();
        isDeleteMode = false;
      });
    } catch (e) {
      print("Error deleting groups: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isDeleteMode ? 'เลือกไว้ ${selectedGroupIds.length} รายการ' : 'กลุ่มของฉัน'),
        leading: IconButton(
          icon: Icon(isDeleteMode ? Icons.close : Icons.arrow_back),
          onPressed: () {
            if (isDeleteMode) {
              setState(() {
                isDeleteMode = false;
                selectedGroupIds.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (!isDeleteMode)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: showCreateGroupDialog,
            ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'delete') {
                setState(() {
                  isDeleteMode = true;
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('ลบกลุ่ม'),
                ),
              ];
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : groups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_outlined, size: 100, color: Colors.grey),
                      Text('ไม่มีกลุ่ม', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          var group = groups[index];
                          bool isSelected = selectedGroupIds.contains(group.id);
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(group.name[0]),
                            ),
                            title: Text(group.name),
                            subtitle: Text('${groupUserCount[group.id] ?? 0} ราย'),
                            trailing: isDeleteMode
                                ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedGroupIds.remove(group.id);
                                        } else {
                                          selectedGroupIds.add(group.id);
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
                                    selectedGroupIds.remove(group.id);
                                  } else {
                                    selectedGroupIds.add(group.id);
                                  }
                                });
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GroupDetailScreen(
                                      groupId: group.id,
                                      groupName: group.name,
                                    ),
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
                          label: Text('ลบกลุ่มที่เลือก'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: selectedGroupIds.isNotEmpty ? Colors.red : Colors.grey,
                          ),
                          onPressed: selectedGroupIds.isNotEmpty
                              ? () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('ลบกลุ่ม'),
                                        content: Text('คุณต้องการลบกลุ่มที่เลือกใช่หรือไม่?'),
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
                                              deleteSelectedGroups();
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
