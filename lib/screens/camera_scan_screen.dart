// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:app_card/screens/request.dart';

// class CameraScanScreen extends StatefulWidget {
//   @override
//   _CameraScanScreenState createState() => _CameraScanScreenState();
// }

// class _CameraScanScreenState extends State<CameraScanScreen> {
//   late CameraController _cameraController;
//   late Future<void> _initializeControllerFuture;
//   bool _isDetecting = false;
//   final BarcodeScanner _barcodeScanner = GoogleMlKit.vision.barcodeScanner();

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   void _initializeCamera() async {
//     final cameras = await availableCameras();
//     final firstCamera = cameras.first;

//     _cameraController = CameraController(
//       firstCamera,
//       ResolutionPreset.medium,
//     );

//     _initializeControllerFuture = _cameraController.initialize().then((_) {
//       _cameraController.startImageStream((CameraImage image) async {
//         if (_isDetecting) return;
//         _isDetecting = true;

//         final WriteBuffer allBytes = WriteBuffer();
//         for (Plane plane in image.planes) {
//           allBytes.putUint8List(plane.bytes);
//         }
//         final bytes = allBytes.done().buffer.asUint8List();

//         final Size imageSize =
//             Size(image.width.toDouble(), image.height.toDouble());

//         // Detect rotation
//         final InputImageRotation imageRotation = InputImageRotationMethods.fromDegrees(
//           _cameraController.description.sensorOrientation,
//         );

//         final inputImageData = InputImageData(
//           size: imageSize,
//           imageRotation: imageRotation,
//           inputImageFormat: InputImageFormatMethods.fromRawValue(image.format.raw) ?? InputImageFormat.nv21,
//           planeData: image.planes.map(
//             (Plane plane) {
//               return InputImagePlaneMetadata(
//                 bytesPerRow: plane.bytesPerRow,
//                 height: plane.height,
//                 width: plane.width,
//               );
//             },
//           ).toList(),
//         );

//         final inputImage = InputImage.fromBytes(
//           bytes: bytes,
//           inputImageData: inputImageData,
//         );

//         final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

//         if (barcodes.isNotEmpty) {
//           final String scannedId = barcodes.first.rawValue ?? '';
//           _cameraController.stopImageStream();
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => UserProfileScreen(userId: scannedId),
//             ),
//           );
//         }

//         _isDetecting = false;
//       });
//     }).catchError((e) {
//       print(e);
//     });
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     _barcodeScanner.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Scan QR from Camera'),
//       ),
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return CameraPreview(_cameraController);
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }
