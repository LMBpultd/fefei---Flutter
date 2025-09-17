import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'pdf_viewer_screen.dart';

class MyDocScreen extends StatelessWidget {
  const MyDocScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pdfFiles = [
      {'name': 'Aadhar Card', 'file': 'aadhar.pdf'},
      {'name': 'Pan Card', 'file': 'pan.pdf'},
      {'name': 'S S L C', 'file': 'sslc.pdf'},
      {'name': 'Plus Two', 'file': 'plustwo.pdf'},
      {'name': 'Birth Certificate', 'file': 'birthcertificate.pdf'},
      {'name': 'Driving Licence', 'file': 'DL.pdf'},
      {'name': 'S B I', 'file': 'sbi.pdf'},
      {'name': 'Jupiter', 'file': 'jupiter.pdf'},
      {'name': 'Ration Card', 'file': 'rc.pdf'},
      {'name': 'B.com', 'file': 'Bcom.pdf'},
      {'name': 'Binu Xavier', 'file': 'Binu-Xavier.pdf'},
      {'name': 'Mini Binu', 'file': 'Mini-Binu.pdf'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('My Documents')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: pdfFiles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 3,
          ),
          itemBuilder: (context, index) {
            final doc = pdfFiles[index];
            final assetPath = 'assets/mydocs/${doc['file']}';
            final fileName = doc['file']!;

            return GestureDetector(
              onLongPress: () async {
                try {
                  final byteData = await rootBundle.load(assetPath);
                  final tempDir = await getTemporaryDirectory();
                  final file = File('${tempDir.path}/$fileName');
                  await file.writeAsBytes(byteData.buffer.asUint8List());

                  await Share.shareXFiles([
                    XFile(file.path),
                  ], text: 'Sharing ${doc['name']} document');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error sharing file: $e')),
                  );
                }
              },
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PDFViewerScreen(
                        pdfAssetPath: assetPath,
                        title: doc['name']!,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: Text(
                  doc['name']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontFamily: 'Playfair Display',
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
