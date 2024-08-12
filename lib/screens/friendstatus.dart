// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class FriendStatsScreen extends StatelessWidget {
//   final String userId;

//   const FriendStatsScreen({Key? key, required this.userId}) : super(key: key);

//   Future<Map<String, int>> _fetchFriendStats() async {
//     final response = await http.get(Uri.parse('https://business-api-638w.onrender.com/friendstats/user/$userId'));

//     if (response.statusCode == 200) {
//       return Map<String, int>.from(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load friend stats');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Friend Stats'),
//       ),
//       body: FutureBuilder<Map<String, int>>(
//         future: _fetchFriendStats(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No stats found'));
//           } else {
//             final stats = snapshot.data!;
//             final data = [
//               FriendStat('Added', stats['addCount'] ?? 0),
//               FriendStat('Deleted', stats['deleteCount'] ?? 0),
//             ];

//             return SfCartesianChart(
//               primaryXAxis: CategoryAxis(),
//               title: ChartTitle(text: 'Friend Add/Delete Stats'),
//               legend: Legend(isVisible: true),
//               tooltipBehavior: TooltipBehavior(enable: true),
//               series: <CartesianSeries>[
//                 BarSeries<FriendStat, String>(
//                   dataSource: data,
//                   xValueMapper: (FriendStat stat, _) => stat.action,
//                   yValueMapper: (FriendStat stat, _) => stat.count,
//                   name: 'Count',
//                   dataLabelSettings: DataLabelSettings(isVisible: true),
//                 )
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// class FriendStat {
//   final String action;
//   final int count;

//   FriendStat(this.action, this.count);
// }
