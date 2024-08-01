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

class FriendStatsTab extends StatelessWidget {
  final String userId;

  const FriendStatsTab({Key? key, required this.userId}) : super(key: key);

  Future<List<History>> _fetchFriendHistory() async {
    final response = await http.get(Uri.parse('https://business-api-638w.onrender.com/history/friend/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => History.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load friend history');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<History>>(
      future: _fetchFriendHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No history found'));
        } else {
          final historyList = snapshot.data!;

          // Aggregate data by date for the graph
          Map<DateTime, int> addDataMap = {};
          Map<DateTime, int> deleteDataMap = {};

          for (var entry in historyList) {
            DateTime date = DateTime.parse(entry.timestamp);
            DateTime dateOnly = DateTime(date.year, date.month, date.day);

            if (entry.action == 'add_friend') {
              addDataMap[dateOnly] = (addDataMap[dateOnly] ?? 0) + 1;
            } else if (entry.action == 'delete_friend') {
              deleteDataMap[dateOnly] = (deleteDataMap[dateOnly] ?? 0) + 1;
            }
          }

          final addData = addDataMap.entries
              .map((e) => FriendStat(e.key, e.value))
              .toList();
          final deleteData = deleteDataMap.entries
              .map((e) => FriendStat(e.key, e.value))
              .toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.0), // Add margin to prevent cutting off
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                      intervalType: DateTimeIntervalType.days,
                      interval: 1,
                      dateFormat: DateFormat('yyyy-MM-dd'),
                      edgeLabelPlacement: EdgeLabelPlacement.shift, // Shift edge labels to prevent cutting off
                      labelAlignment: LabelAlignment.end,
                    ),
                    title: ChartTitle(text: 'Friend Stats Over Time'),
                    legend: Legend(isVisible: true),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries>[
                      ColumnSeries<FriendStat, DateTime>(
                        dataSource: addData,
                        xValueMapper: (FriendStat stat, _) => stat.date,
                        yValueMapper: (FriendStat stat, _) => stat.count,
                        name: 'Added',
                        color: Colors.green,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                      ColumnSeries<FriendStat, DateTime>(
                        dataSource: deleteData,
                        xValueMapper: (FriendStat stat, _) => stat.date,
                        yValueMapper: (FriendStat stat, _) => stat.count,
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

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => History.fromJson(item)).toList();
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
                      title: Text('${history.action} with ${history.friendId}'),
                      subtitle: Text(history.timestamp),
                    );
                  } else if (userSnapshot.hasError) {
                    return ListTile(
                      title: Text('${history.action} with ${history.friendId}'),
                      subtitle: Text(history.timestamp),
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

class FriendStat {
  final DateTime date;
  final int count;

  FriendStat(this.date, this.count);
}
