import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityWidget extends StatefulWidget {
  final Widget child;

  const ConnectivityWidget({Key? key, required this.child}) : super(key: key);

  @override
  _ConnectivityWidgetState createState() => _ConnectivityWidgetState();
}

class _ConnectivityWidgetState extends State<ConnectivityWidget> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      setState(() {
        _isConnected = results.any((result) => result != ConnectivityResult.none);
      });
    });
  }

  Future<void> _checkConnectivity() async {
    final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = results.any((result) => result != ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ไม่มีการเชื่อมต่ออินเทอร์เน็ต'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'คุณไม่ได้เชื่อมต่ออินเทอร์เน็ต',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _checkConnectivity();
                },
                child: const Text('ตรวจสอบการเชื่อมต่อ'),
              ),
            ],
          ),
        ),
      );
    }
    return widget.child;
  }
}
