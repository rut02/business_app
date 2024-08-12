import 'package:app_card/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class QRCodeScreen extends StatelessWidget {
  final ScreenshotController screenshotController = ScreenshotController();

  Future<bool> saveQRCode() async {
    try {
      final image = await screenshotController.capture();
      if (image != null) {
        final result = await ImageGallerySaver.saveImage(image, quality: 100, name: 'qr_code');
        if (result != null && result['isSuccess']) {
          return true;
        }
      }
    } catch (e) {
      print('ข้อผิดพลาดในการบันทึก QR code: $e');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    final userId = loginProvider.login?.id ?? 'Unknown';
    final appLink =  'https://web-deep.onrender.com/request/$userId';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('หน้า QR CODE'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'QR CODE ของคุณ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Screenshot(
                controller: screenshotController,
                child: Container(
                  color: Colors.grey[300],
                  padding: EdgeInsets.all(16),
                  child: QrImageView(
                    data: appLink,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: appLink));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ลิงก์ถูกคัดลอกไปยังคลิปบอร์ด!'),
                    ),
                  );
                },
                child: Text('แชร์ลิงก์'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final success = await saveQRCode();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'QR code ถูกบันทึกไปยังแกลเลอรี!' : 'ล้มเหลวในการบันทึก QR code.'),
                    ),
                  );
                },
                child: Text('บันทึก QR Code'),
              ),
              SizedBox(height: 20),
              Text(
                'นี่คือที่ที่ QR code ของคุณจะปรากฏ',
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
        currentIndex: 3,
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