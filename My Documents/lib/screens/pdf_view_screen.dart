import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart'; // Add this package in pubspec.yaml

class PdfViewScreen extends StatefulWidget {
  final File file;

  const PdfViewScreen({super.key, required this.file});

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
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

  Future<void> _sharePdf() async {
    if (await widget.file.exists()) {
      await Share.shareXFiles([XFile(widget.file.path)], text: 'Check out this PDF!');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File not found')),
      );
    }
  }

  Future<void> _deletePdf() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete PDF'),
        content: Text('Are you sure you want to delete this file?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.file.delete();
        Navigator.pop(context, true); // Return true to indicate deletion
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.file.path.split('/').last;

    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _sharePdf,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deletePdf,
          ),
        ],
      ),
      body: PdfViewPinch(controller: _pdfController),
    );
  }
}
