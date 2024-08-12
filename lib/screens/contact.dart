import 'package:app_card/screens/detailscreen.dart';
import 'package:app_card/screens/group.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_card/models/friend.dart';
import 'package:app_card/models/user.dart';
import 'package:app_card/services/friends.dart';
import 'package:app_card/services/users.dart';
import 'package:app_card/login_provider.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<UserWithStatus> friends = [];
  List<UserWithStatus> filteredFriends = [];
  final FriendService friendService = FriendService();
  final UserService userService = UserService();
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadFriends();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase();
        filteredFriends = friends.where((userWithStatus) {
          var user = userWithStatus.user;
          return user.firstname.toLowerCase().contains(searchQuery) ||
              user.lastname.toLowerCase().contains(searchQuery) ||
              user.position.toLowerCase().contains(searchQuery) ||
              (user.companybranch?.company.name
                      .toLowerCase()
                      .contains(searchQuery) ??
                  false);
        }).toList();
      });
    });
  }

  Future<void> loadFriends() async {
    setState(() {
      isLoading = true;
    });

    final loginProvider = context.read<LoginProvider>();
    String? userId = loginProvider.login?.id;

    if (userId == null) {
      print('User ID is null');
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      var friendsList = await friendService.getFriendByuserId(userId);
      List<UserWithStatus> usersWithStatusList = [];
      for (var friend in friendsList) {
        var user = await userService.getUserByid(friend.friendId);
        if (user != null) {
          usersWithStatusList.add(UserWithStatus(
            user: user,
            status: friend.status,
            time: friend.time,
          ));
        }
      }

      usersWithStatusList.sort((a, b) => b.status.compareTo(a.status));

      setState(() {
        friends = usersWithStatusList;
        filteredFriends = usersWithStatusList;
      });
    } catch (e) {
      print('เกิดข้อผิดพลาดในการโหลดเพื่อน: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleFriendStatus(UserWithStatus userWithStatus, String userId) async {
    String newStatus = userWithStatus.status == "1" ? "0" : "1";
    await friendService.updateFriendStatus(
        userId, userWithStatus.user.id, newStatus);
    setState(() {
      userWithStatus.status = newStatus;
      friends.sort((a, b) => b.status.compareTo(a.status));
      filteredFriends.sort((a, b) => b.status.compareTo(a.status));
    });
  }

  void sortFriends(String criterion) {
    setState(() {
      if (criterion == 'date') {
        friends.sort((a, b) => b.time.compareTo(a.time));
      } else if (criterion == 'name') {
        friends.sort((a, b) => a.user.firstname.compareTo(b.user.firstname));
      } else if (criterion == 'company') {
        friends.sort((a, b) =>
            a.user.companybranch?.company.name
                .compareTo(b.user.companybranch?.company.name ?? '') ??
            0);
      }
      filteredFriends = friends;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.read<LoginProvider>();
    String? userId = loginProvider.login?.id;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('หน้าติดต่อ'),
        actions: [
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'ค้นหา',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              hint: Text('เรียงลำดับโดย'),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  sortFriends(newValue);
                }
              },
              items: <String>['date', 'name', 'company']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value == 'date'
                      ? 'วัน'
                      : value == 'name'
                          ? 'ชื่อ'
                          : 'บริษัท'),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Text('จำนวนรายชื่อผู้ติดต่อ: ${filteredFriends.length}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredFriends.length,
                      itemBuilder: (context, index) {
                        var userWithStatus = filteredFriends[index];
                        var user = userWithStatus.user;
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.profile != null
                                  ? NetworkImage(user.profile!)
                                  : AssetImage('assets/default_profile.png')
                                      as ImageProvider,
                            ),
                            title: Text('${user.firstname} ${user.lastname}'),
                            subtitle: Text(
                                'อีเมล: ${user.email}\nตำแหน่ง: ${user.position}'),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.star,
                                color: userWithStatus.status == "1"
                                    ? Colors.yellow
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                if (userId != null) {
                                  toggleFriendStatus(userWithStatus, userId);
                                }
                              },
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailPage(userId: user.id),
                                ),
                              );
                              if (result != null && result as bool) {
                                loadFriends(); // โหลดข้อมูลใหม่หากมีการลบเพื่อน
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'ติดต่อ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'สแกน QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR CODE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'ตั้งค่า',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/contact');
              break;
            case 2:
              context.go('/scan_qr');
              break;
            case 3:
              context.go('/qr_code');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
      ),
    );
  }
}

class UserWithStatus {
  final User user;
  String status;
  String time;

  UserWithStatus(
      {required this.user, required this.status, required this.time});
}
