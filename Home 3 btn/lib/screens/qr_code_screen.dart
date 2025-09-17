import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Model class for each QR button
class QrButton {
  final String label;
  final String imageName;

  const QrButton({required this.label, required this.imageName});
}

class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({super.key});

  // List of buttons with custom label and image name
  final List<QrButton> buttons = const [
    QrButton(label: 'Kotak Mahindra Bank', imageName: 'kotak'),
    QrButton(label: 'State Bank of India Bank', imageName: 'sbi'),
    QrButton(label: 'Jupiter Money', imageName: 'jupiter'),
    QrButton(label: 'Bank of Baroda', imageName: 'bob'),
    QrButton(label: 'Amazon pay', imageName: 'amazon'),
  ];

  // Method to share image on long press
  Future<void> _shareImage(String imageName) async {
    try {
      final ByteData bytes = await rootBundle.load('assets/qr/$imageName.png');
      final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/$imageName.png').create();
      await file.writeAsBytes(list);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Sharing $imageName QR');
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  // Method to show image in dialog on tap
  void _showImageDialog(BuildContext context, String imageName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Image.asset('assets/qr/$imageName.png'),
        title: Text(imageName.toUpperCase()),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UPI QR Code')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: buttons.map((item) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _showImageDialog(context, item.imageName),
              onLongPress: () => _shareImage(item.imageName),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 35,
                  fontFamily: 'Playfair Display',
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
