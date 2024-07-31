import 'package:app_card/login_provider.dart';
import 'package:flutter/material.dart';
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
      print('Error saving QR code: $e');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    final userId = loginProvider.login?.id ?? 'Unknown';
    final appLink = userId; // 'https://yourapp.com/requests?userId=$userId';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('QR CODE PAGE'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'YOUR QR CODE',
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
                      content: Text('Link copied to clipboard!'),
                    ),
                  );
                },
                child: Text('Share Link'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final success = await saveQRCode();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'QR code saved to gallery!' : 'Failed to save QR code.'),
                    ),
                  );
                },
                child: Text('Save QR Code'),
              ),
              SizedBox(height: 20),
              Text(
                'This is where your QR code will appear.',
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
        currentIndex: 3,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
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
