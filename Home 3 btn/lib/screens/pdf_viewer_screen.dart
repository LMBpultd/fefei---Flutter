import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class PDFViewerScreen extends StatelessWidget {
  final String pdfAssetPath;
  final String title;

  const PDFViewerScreen({
    super.key,
    required this.pdfAssetPath,
    required this.title,
  });

  Future<void> _sharePDF() async {
    try {
      // Load PDF from assets
      final bytes = await rootBundle.load(pdfAssetPath);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${pdfAssetPath.split('/').last}');
      await tempFile.writeAsBytes(bytes.buffer.asUint8List());

      // Share the PDF
      await Share.shareXFiles([XFile(tempFile.path)], text: 'Sharing $title');
    } catch (e) {
      print('Error sharing PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdfController = PdfController(
      document: PdfDocument.openAsset(pdfAssetPath),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePDF,
          ),
        ],
      ),
      body: PdfView(
        controller: pdfController,
      ),
    );
  }
}
