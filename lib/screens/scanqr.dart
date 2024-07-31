import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_card/screens/request.dart';
import 'package:provider/provider.dart';
import 'package:app_card/login_provider.dart'; // เพิ่มการนำเข้า LoginProvider

class ScanQRScreen extends StatefulWidget {
  @override
  _ScanQRScreenState createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  String _scanResult = '';
  QRViewController? _controller;
  bool _isScanning = false;

  Future<void> pickImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _scanQRCodeFromFile(File(image.path));
    }
  }

  void _scanQRCodeFromFile(File imageFile) async {
    final apiUrl = Uri.parse('https://business-api-638w.onrender.com/scan'); // เปลี่ยนเป็น URL ของ API ของคุณ
    final request = http.MultipartRequest('POST', apiUrl);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final result = json.decode(responseData);
      final String scannedId = result['result'];
      final String currentUserId = Provider.of<LoginProvider>(context, listen: false).login?.id ?? '';

      if (scannedId == currentUserId) {
        setState(() {
          _scanResult = 'คุณไม่สามารถสแกน QR โค้ดของตัวเองได้';
        });
        return;
      }

      setState(() {
        _scanResult = 'ผลลัพธ์ QR โค้ด: $scannedId';
      });

      // นำทางไปยังหน้าจอ UserProfileScreen พร้อมกับ ID ที่สแกนได้
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(contactId: scannedId),
        ),
      );
    } else {
      setState(() {
        _scanResult = 'เกิดข้อผิดพลาดในการสแกน QR โค้ดจากไฟล์';
      });
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isScanning) return;

      final String scannedId = scanData.code ?? '';
      final String currentUserId = Provider.of<LoginProvider>(context, listen: false).login?.id ?? '';

      if (scannedId == currentUserId) {
        setState(() {
          _scanResult = 'คุณไม่สามารถสแกน QR โค้ดของตัวเองได้';
        });
        return;
      }

      setState(() {
        _isScanning = true;
        _scanResult = 'ผลลัพธ์ QR โค้ด: $scannedId';
      });

      // หยุดการทำงานของกล้อง
      await _controller?.pauseCamera();

      // นำทางไปยังหน้าจอ UserProfileScreen พร้อมกับ ID ที่สแกนได้
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(contactId: scannedId),
        ),
      ).then((_) async {
        // กลับมาทำงานของกล้องใหม่
        await _controller?.resumeCamera();
        setState(() {
          _isScanning = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('หน้าสแกน QR'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              child: QRView(
                key: _qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'สแกน QR โค้ด',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_controller != null) {
                        _controller!.pauseCamera();
                      }
                      pickImage(context);
                    },
                    child: Text('เลือกภาพจากแกลเลอรี'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'ผลลัพธ์การสแกน: $_scanResult',
                    textAlign: TextAlign.center,
                  ),
                ],
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
            label: 'QR โค้ด',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'ตั้งค่า',
          ),
        ],
        currentIndex: 2,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          if (_controller != null) {
            _controller!.pauseCamera();
          }

          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/contact');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/scan_qr');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/qr_code');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}
