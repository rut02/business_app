// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';

// class ConnectivityService {
//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription<ConnectivityResult> _subscription;

//   // Stream สำหรับแจ้งเตือนผู้ฟังเมื่อสถานะการเชื่อมต่อเปลี่ยนแปลง
//   final StreamController<bool> _connectionStatusController =
//       StreamController<bool>.broadcast();
//   Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

//   ConnectivityService() {
//     _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
//     _checkInitialConnection();
//   }

//   void _updateConnectionStatus(ConnectivityResult result) {
//     // ถ้าผลลัพธ์ไม่ใช่ none แสดงว่ามีการเชื่อมต่อ
//     bool isConnected = result != ConnectivityResult.none;
//     _connectionStatusController.add(isConnected);
//   }

//   Future<void> _checkInitialConnection() async {
//     ConnectivityResult result = await _connectivity.checkConnectivity();
//     _updateConnectionStatus(result);
//   }

//   void dispose() {
//     _subscription.cancel();
//     _connectionStatusController.close();
//   }
// }
