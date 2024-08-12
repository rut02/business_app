import 'package:app_card/models/history.dart';
import 'package:app_card/models/user.dart';
import 'package:app_card/services/users.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class CombinedScreen extends StatelessWidget {
  final String userId;

  const CombinedScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('สถิติและประวัติผู้ใช้'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'สถิติเพื่อน'),
              Tab(text: 'ประวัติ'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FriendStatsTab(userId: userId),
            HistoryTab(userId: userId),
          ],
        ),
      ),
    );
  }
}

class FriendStatsTab extends StatefulWidget {
  final String userId;

  const FriendStatsTab({Key? key, required this.userId}) : super(key: key);

  @override
  _FriendStatsTabState createState() => _FriendStatsTabState();
}

class _FriendStatsTabState extends State<FriendStatsTab> {
  String _selectedRange = 'All';
  Future<List<History>>? _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchFriendHistory(_selectedRange);
  }

  Future<List<History>> _fetchFriendHistory(String range) async {
    final response = await http.get(Uri.parse(
        'https://business-api-638w.onrender.com/history/friend/${widget.userId}'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<History> historyList =
          data.map((item) => History.fromJson(item)).toList();

      if (range != 'All') {
        DateTime now = DateTime.now();
        historyList = historyList.where((history) {
          DateTime date = DateTime.parse(history.timestamp);
          if (range == '1 Day') {
            return date.isAfter(now.subtract(Duration(days: 1)));
          } else if (range == '1 Week') {
            return date.isAfter(now.subtract(Duration(days: 7)));
          } else if (range == '1 Month') {
            return date.isAfter(now.subtract(Duration(days: 30)));
          }
          return false;
        }).toList();
      }

      return historyList;
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('ไม่สามารถโหลดประวัติเพื่อนได้');
    }
  }

  void _updateRange(String? newValue) {
    setState(() {
      _selectedRange = newValue!;
      _historyFuture = _fetchFriendHistory(_selectedRange);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<History>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('ข้อผิดพลาด: ${snapshot.error}'));
        } else {
          final historyList = snapshot.data ?? [];

          int totalAdded = 0;
          int totalDeleted = 0;

          for (var entry in historyList) {
            if (entry.action == 'add_friend') {
              totalAdded += 1;
            } else if (entry.action == 'delete_friend') {
              totalDeleted += 1;
            }
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButton<String>(
                    value: _selectedRange,
                    onChanged: _updateRange,
                    items: <String>['All', '1 Day', '1 Week', '1 Month']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: totalAdded.toDouble(),
                                color: Colors.green,
                                width: 16,
                                borderRadius: BorderRadius.zero,
                                rodStackItems: [
                                  BarChartRodStackItem(
                                      0, totalAdded.toDouble(), Colors.green),
                                ],
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: totalAdded.toDouble(),
                                  color: Colors.green.withOpacity(0.2),
                                ),
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: totalDeleted.toDouble(),
                                color: Colors.red,
                                width: 16,
                                borderRadius: BorderRadius.zero,
                                rodStackItems: [
                                  BarChartRodStackItem(
                                      0, totalDeleted.toDouble(), Colors.red),
                                ],
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: totalDeleted.toDouble(),
                                  color: Colors.red.withOpacity(0.2),
                                ),
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                              reservedSize: 32,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value == 0 ? 'เพิ่ม' : 'ลบ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                              reservedSize: 32,
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false, // ซ่อนค่าแกน x ด้านบน
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false, // ซ่อนค่าแกน y ด้านขวา
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            // tooltipBgColor: Colors.blueAccent,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              String label = group.x == 0 ? 'เพิ่ม' : 'ลบ';
                              return BarTooltipItem(
                                '$label: ${rod.toY.toInt()}',
                                TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        maxY: (totalAdded > totalDeleted
                                    ? totalAdded
                                    : totalDeleted)
                                .toDouble() +
                            1,
                        minY: 0,
                      ),
                    ),
                  ),
                  if (historyList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'ไม่พบข้อมูลสำหรับช่วงเวลาที่เลือก',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

// class FriendStats {
//   final DateTime date;
//   int added;
//   int deleted;

//   FriendStats(this.date, this.added, this.deleted);
// }
class HistoryTab extends StatefulWidget {
  final String userId;

  const HistoryTab({Key? key, required this.userId}) : super(key: key);

  @override
  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final UserService userService = UserService();
  Future<List<History>>? _historyFuture;
  final Map<String, String> _userNamesCache = {};

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
  }

  Future<List<History>> _fetchHistory() async {
    final response = await http.get(Uri.parse(
        'https://business-api-638w.onrender.com/history/user/${widget.userId}'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => History.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('ไม่สามารถโหลดประวัติได้');
    }
  }

  Future<String> _getUserName(String userId) async {
    if (_userNamesCache.containsKey(userId)) {
      return _userNamesCache[userId]!;
    } else {
      User user = await userService.getUserByid(userId);
      String userName = "${user.firstname} ${user.lastname}";
      _userNamesCache[userId] = userName;
      return userName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<History>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 60),
                SizedBox(height: 16),
                Text('ข้อผิดพลาด: ${snapshot.error}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _historyFuture = _fetchHistory(); // Retry fetching data
                    });
                  },
                  child: Text('ลองอีกครั้ง'),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('ไม่พบประวัติ', style: TextStyle(fontSize: 16)),
          );
        } else {
          return ListView.separated(
            padding: EdgeInsets.all(8.0),
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              final history = snapshot.data![index];
              return HistoryListItem(
                history: history,
                getUserName: _getUserName,
              );
            },
          );
        }
      },
    );
  }
}

class HistoryListItem extends StatelessWidget {
  final History history;
  final Future<String> Function(String userId) getUserName;

  const HistoryListItem({
    Key? key,
    required this.history,
    required this.getUserName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getUserName(history.friendId),
      builder: (context, snapshot) {
        return ListTile(
          leading: Icon(
            history.action == 'add_friend'
                ? Icons.person_add
                : Icons.person_remove,
            color: history.action == 'add_friend'
                ? Colors.green
                : Colors.red,
          ),
          title: Text(
            '${history.action == 'add_friend' ? 'เพิ่ม' : 'ลบ'} เพื่อน: ${snapshot.connectionState == ConnectionState.waiting ? 'กำลังโหลด...' : snapshot.data}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(history.timestamp)),
          ),
        );
      },
    );
  }
}
