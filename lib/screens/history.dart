import 'package:app_card/models/history.dart';
import 'package:app_card/models/user.dart';
import 'package:app_card/services/users.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
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
          title: Text('User Stats and History'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Friend Stats'),
              Tab(text: 'History'),
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
    final response = await http.get(Uri.parse('https://business-api-638w.onrender.com/history/friend/${widget.userId}'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<History> historyList = data.map((item) => History.fromJson(item)).toList();

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
      throw Exception('Failed to load friend history');
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
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No history found'));
        } else {
          final historyList = snapshot.data!;

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
            child: Column(
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
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    title: ChartTitle(text: 'Friend Stats Over Time'),
                    legend: Legend(isVisible: true),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries>[
                      ColumnSeries<ChartData, String>(
                        dataSource: [
                          ChartData('Added', totalAdded),
                        ],
                        xValueMapper: (ChartData data, _) => data.category,
                        yValueMapper: (ChartData data, _) => data.value,
                        name: 'Added',
                        color: Colors.green,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                      ColumnSeries<ChartData, String>(
                        dataSource: [
                          ChartData('Deleted', totalDeleted),
                        ],
                        xValueMapper: (ChartData data, _) => data.category,
                        yValueMapper: (ChartData data, _) => data.value,
                        name: 'Deleted',
                        color: Colors.red,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class ChartData {
  final String category;
  final int value;

  ChartData(this.category, this.value);
}

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
    final response = await http.get(Uri.parse('https://business-api-638w.onrender.com/history/user/${widget.userId}'));
    print(response.statusCode);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => History.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load history');
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
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No history found'));
        } else {
          final historyList = snapshot.data!;
          return ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final history = historyList[index];
              return FutureBuilder<String>(
                future: _getUserName(history.friendId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      leading: Icon(
                        history.action == 'add_friend' ? Icons.person_add : Icons.person_remove,
                        color: history.action == 'add_friend' ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        '${history.action == 'add_friend' ? 'Added' : 'Deleted'} friend: Loading...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(history.timestamp)),
                      ),
                    );
                  } else if (userSnapshot.hasError) {
                    return ListTile(
                      leading: Icon(
                        history.action == 'add_friend' ? Icons.person_add : Icons.person_remove,
                        color: history.action == 'add_friend' ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        '${history.action == 'add_friend' ? 'Added' : 'Deleted'} friend: Error',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(history.timestamp)),
                      ),
                      trailing: Icon(Icons.error, color: Colors.red),
                    );
                  } else {
                    return ListTile(
                      leading: Icon(
                        history.action == 'add_friend' ? Icons.person_add : Icons.person_remove,
                        color: history.action == 'add_friend' ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        '${history.action == 'add_friend' ? 'Added' : 'Deleted'} friend: ${userSnapshot.data}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(history.timestamp)),
                      ),
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }
}

class FriendStats {
  final DateTime date;
  int added;
  int deleted;

  FriendStats(this.date, this.added, this.deleted);
}
