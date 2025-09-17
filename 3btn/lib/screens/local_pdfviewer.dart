import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class LocalPdfViewer extends StatefulWidget {
  final File file;

  const LocalPdfViewer({Key? key, required this.file}) : super(key: key);

  @override
  State<LocalPdfViewer> createState() => _LocalPdfViewerState();
}

class _LocalPdfViewerState extends State<LocalPdfViewer> {
  late PdfControllerPinch _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openFile(widget.file.path),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.uri.pathSegments.last),
      ),
      body: PdfViewPinch(
        controller: _pdfController,
      ),
    );
  }
}
