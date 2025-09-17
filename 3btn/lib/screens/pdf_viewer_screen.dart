import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PDFViewerScreen extends StatelessWidget {
  final String pdfAssetPath;
  final String title;

  const PDFViewerScreen({
    super.key,
    required this.pdfAssetPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final pdfController = PdfController(
      document: PdfDocument.openAsset(pdfAssetPath),
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfView(
        controller: pdfController,
      ),
    );
  }
}
