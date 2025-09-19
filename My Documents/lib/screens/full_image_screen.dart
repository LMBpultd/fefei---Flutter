import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class FullImageScreen extends StatefulWidget {
  final File image;
  const FullImageScreen({required this.image, super.key});

  @override
  State<FullImageScreen> createState() => _FullImageScreenState();
}

class _FullImageScreenState extends State<FullImageScreen> {
  late File _image;

  @override
  void initState() {
    super.initState();
    _image = widget.image;
  }

  Future<void> _deleteImage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image?'),
        content: Text('Are you sure you want to delete "${p.basename(_image.path)}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      await _image.delete();
      if (!mounted) return;
      Navigator.pop(context, true); // Signal deletion to previous screen
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image deleted')));
    }
  }

  void _shareImage() {
    Share.shareXFiles([XFile(_image.path)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(p.basename(_image.path)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: _deleteImage,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: _shareImage,
          ),
        ],
      ),
      body: Center(child: Image.file(_image)),
    );
  }
}
