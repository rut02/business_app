import 'package:app_card/services/friends.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_card/models/request.dart';
import 'package:app_card/models/user.dart';
import 'package:app_card/services/requests.dart';
import 'package:app_card/services/users.dart';
import 'package:app_card/login_provider.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Request> pendingRequests = [];
  final RequestServices requestService = RequestServices();
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    loadPendingRequests();
    Provider.of<LoginProvider>(context, listen: false).addListener(() {
      loadPendingRequests();
    });
  }

  Future<void> loadPendingRequests() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    String userId = loginProvider.login!.id;

    try {
      var requests = await requestService.getRequestByresponder(userId);
      setState(() {
        pendingRequests = requests.where((req) => req.status == '0').toList();
      });
      if (requests.isNotEmpty) {
        //await showNotification('New Request', 'คุณมีคำขอใหม่');
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการโหลดคำขอ: $e');
    }
  }

  Future<void> respondToRequest(Request request, String status) async {
    try {
      await requestService.updateRequestStatus(request.id, status);

      setState(() {
        pendingRequests.removeWhere((r) => r.id == request.id);
      });

      String message = status == '1' ? 'ยืนยันคำขอแล้ว' : 'ยกเลิกคำขอแล้ว';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      //await showNotification('การตอบรับคำขอ', message);

      // Call createFriend if the request is accepted
      if (status == '1') {
        final loginProvider = Provider.of<LoginProvider>(context, listen: false);
        String userId = loginProvider.login!.id;
        await FriendService().createFriend(userId, request.requesterId);
        await FriendService().createFriend(request.requesterId, userId);
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการตอบคำขอ: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('การแจ้งเตือน'),
      ),
      body: pendingRequests.isEmpty
          ? Center(child: Text('ไม่มีคำขอรอดำเนินการ'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: pendingRequests.length,
                itemBuilder: (context, index) {
                  var request = pendingRequests[index];
                  return FutureBuilder<User>(
                    future: userService.getUserByid(request.requesterId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return ListTile(
                          title: Text('เกิดข้อผิดพลาดในการดึงข้อมูลผู้ใช้'),
                        );
                      } else if (!snapshot.hasData) {
                        return ListTile(
                          title: Text('ไม่พบข้อมูลผู้ใช้'),
                        );
                      } else {
                        var user = snapshot.data;
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.notification_important),
                            title: Text('${user?.firstname} ${user?.lastname}'),
                            subtitle: Text('คำขอจาก ${user?.email}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check),
                                  color: Colors.green,
                                  onPressed: () => respondToRequest(request, '1'),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  color: Colors.red,
                                  onPressed: () => respondToRequest(request, 'declined'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'CONTACT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'SCAN QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR CODE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'SETTINGS',
          ),
        ],
        currentIndex: 0,
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
