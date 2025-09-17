import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart'; // Add share_plus in pubspec.yaml

import 'local_pdfviewer.dart';

class OtherDocScreen extends StatefulWidget {
  const OtherDocScreen({Key? key}) : super(key: key);

  @override
  State<OtherDocScreen> createState() => _OtherDocScreenState();
}

class _OtherDocScreenState extends State<OtherDocScreen> {
  List<File> _pdfFiles = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPdfs();
  }

  Future<void> _loadSavedPdfs() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync();
    final pdfs = files.where((file) => file.path.toLowerCase().endsWith('.pdf')).toList();

    setState(() {
      _pdfFiles = pdfs.map((f) => File(f.path)).toList();
    });
  }

  Future<void> _pickAndSavePdf() async {
    final typeGroup = XTypeGroup(label: 'PDF', extensions: ['pdf']);

    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      final bytes = await file.readAsBytes();
      final dir = await getApplicationDocumentsDirectory();
      final newFile = File('${dir.path}/${file.name}');

      await newFile.writeAsBytes(bytes);

      setState(() {
        _pdfFiles.add(newFile);
      });
    }
  }

  void _openPdf(File file) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocalPdfViewer(file: file),
      ),
    );
  }

  String _removePdfExtension(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return fileName.substring(0, fileName.length - 4);
    }
    return fileName;
  }

  Future<void> _renameFile(File file) async {
    final currentName = file.uri.pathSegments.last;
    final baseName = _removePdfExtension(currentName);

    final TextEditingController controller = TextEditingController(text: baseName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename PDF'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != baseName) {
      final newPath = file.parent.path + '/$newName.pdf';
      final newFile = await file.rename(newPath);

      setState(() {
        final index = _pdfFiles.indexOf(file);
        _pdfFiles[index] = newFile;
      });
    }
  }

  void _shareFile(File file) {
    Share.shareFiles([file.path], text: 'Sharing PDF file: ${file.uri.pathSegments.last}');
  }

  Future<void> _deleteFile(File file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete PDF'),
        content: Text('Are you sure you want to delete "${file.uri.pathSegments.last}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await file.delete();

      setState(() {
        _pdfFiles.remove(file);
      });
    }
  }

  void _showOptions(File file) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _renameFile(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _shareFile(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteFile(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _multiSelectFiles() async {
    final selectedFiles = <File>{};

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select PDFs',
             style: TextStyle(
    fontFamily: 'Playfair Display',),),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _pdfFiles.length,
                itemBuilder: (context, index) {
                  final file = _pdfFiles[index];
                  final fileName = _removePdfExtension(file.uri.pathSegments.last);
                  final isSelected = selectedFiles.contains(file);
                  return CheckboxListTile(
                    title: Text(fileName),
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedFiles.add(file);
                        } else {
                          selectedFiles.remove(file);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
             style: TextStyle(
    fontFamily: 'Playfair Display',
  )),
              ),
              TextButton(
                onPressed: selectedFiles.isEmpty
                    ? null
                    : () async {
                        Navigator.pop(context); // Close select dialog

                        final action = await showModalBottomSheet<String>(
                          context: context,
                          builder: (context) {
                            return SafeArea(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.share),
                                    title: const Text('Share Selected',
             style: TextStyle(
    fontFamily: 'Playfair Display',
  )),
                                    onTap: () => Navigator.pop(context, 'share'),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.delete, color: Colors.red),
                                    title: const Text('Delete Selected', style: TextStyle(color: Colors.red)),
                                    onTap: () => Navigator.pop(context, 'delete'),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.cancel),
                                    title: const Text('Cancel'),
                                    onTap: () => Navigator.pop(context, null),
                                  ),
                                ],
                              ),
                            );
                          },
                        );

                        if (action == 'share') {
                          // Share all selected files
                          Share.shareFiles(
                            selectedFiles.map((f) => f.path).toList(),
                            text: 'Sharing multiple PDF files',
                          );
                        } else if (action == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete PDFs'),
                              content: Text('Are you sure you want to delete ${selectedFiles.length} files?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            for (var file in selectedFiles) {
                              await file.delete();
                            }
                            setState(() {
                              _pdfFiles.removeWhere((f) => selectedFiles.contains(f));
                            });
                          }
                        }
                      },
                child: const Text('Proceed',
             style: TextStyle(
    fontFamily: 'Playfair Display',
  )),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Other Documents')),
      body: _pdfFiles.isEmpty
          ? const Center(child: Text('No PDF files added yet.'))
          : ListView.builder(
              itemCount: _pdfFiles.length,
              itemBuilder: (context, index) {
                final file = _pdfFiles[index];
                return ListTile(
                  title: Text(
                    _removePdfExtension(file.uri.pathSegments.last),
                    style: const TextStyle(
                      fontSize: 30,
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                  leading: const Icon(Icons.picture_as_pdf),
                  onTap: () => _openPdf(file),
                  onLongPress: () => _showOptions(file),
                );
              },
            ),
      floatingActionButton: GestureDetector(
        onLongPress: _multiSelectFiles,
        child: FloatingActionButton(
          onPressed: _pickAndSavePdf,
          backgroundColor: Colors.blue,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
