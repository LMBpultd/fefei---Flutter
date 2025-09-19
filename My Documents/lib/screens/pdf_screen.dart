import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'pdf_view_screen.dart';
import 'images_screen.dart'; // Make sure you have this file!

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'My Pdf Documents', home: PdfScreen());
  }
}

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key});
  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  List<File> pdfFiles = [];
  bool isMultiSelectMode = false;
  Set<int> selectedIndexes = {};
  Future<void> pickPdfs() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final appDocDir = await getApplicationDocumentsDirectory();
        List<File> newFiles = [];
        for (var file in result.files) {
          if (file.path != null) {
            String originalName = p.basenameWithoutExtension(file.path!);
            String extension = p.extension(file.path!);
            String newFileName = originalName + extension;
            File newFile = File('${appDocDir.path}/$newFileName');
            int duplicateCount = 1;
            // Find unique filename with number suffix
            while (await newFile.exists()) {
              newFileName = '$originalName($duplicateCount)$extension';
              newFile = File('${appDocDir.path}/$newFileName');
              duplicateCount++;
            }
            await File(file.path!).copy(newFile.path);
            newFiles.add(newFile);
          }
        }
        setState(() {
          pdfFiles.addAll(newFiles);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking files: $e')));
    }
  }

  void toggleMultiSelectMode() {
    setState(() {
      isMultiSelectMode = !isMultiSelectMode;
      selectedIndexes.clear();
    });
  }

  void toggleSelectIndex(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  void deleteSelected() {
    setState(() {
      final indexes = selectedIndexes.toList()..sort((a, b) => b.compareTo(a));
      for (var i in indexes) {
        final fileToDelete = pdfFiles[i];
        try {
          if (fileToDelete.existsSync()) {
            fileToDelete.deleteSync();
          }
        } catch (e) {
          // ignore errors here for simplicity
        }
        pdfFiles.removeAt(i);
      }
      selectedIndexes.clear();
      isMultiSelectMode = false;
    });
  }

  Future<void> shareSelected() async {
    if (selectedIndexes.isEmpty) return;
    final filesToShare = selectedIndexes
        .map((index) => pdfFiles[index].path)
        .toList();
    try {
      await Share.shareXFiles(
        filesToShare.map((path) => XFile(path)).toList(),
        text: 'Sharing PDF files',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sharing files: $e')));
    }
  }

  void _showOptionsDialog(BuildContext context, int index) {
    String currentName = p.basenameWithoutExtension(pdfFiles[index].path);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(currentName),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Rename button
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                tooltip: 'Rename',
                onPressed: () {
                  Navigator.of(context).pop(); // close the dialog
                  _showRenameDialog(context, index);
                },
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
                onPressed: () {
                  Navigator.of(context).pop(); // close the dialog
                  _confirmDelete(context, index);
                },
              ),
              // Share button
              IconButton(
                icon: const Icon(Icons.share, color: Colors.green),
                tooltip: 'Share',
                onPressed: () async {
                  Navigator.of(context).pop(); // close the dialog
                  try {
                    await Share.shareXFiles([
                      XFile(pdfFiles[index].path),
                    ], text: 'Sharing PDF file: $currentName');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error sharing file: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, int index) {
    String currentName = p.basenameWithoutExtension(pdfFiles[index].path);
    TextEditingController controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename PDF'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'New name',
              hintText: 'Enter new file name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newName = controller.text.trim();
                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name cannot be empty')),
                  );
                  return;
                }
                final oldFile = pdfFiles[index];
                final dir = oldFile.parent;
                String extension = p.extension(oldFile.path);
                String newPath = p.join(dir.path, '$newName$extension');
                // Check for duplicates, add suffix if needed
                int duplicateCount = 1;
                while (await File(newPath).exists()) {
                  newPath = p.join(
                    dir.path,
                    '$newName($duplicateCount)$extension',
                  );
                  duplicateCount++;
                }
                try {
                  await oldFile.rename(newPath);
                  setState(() {
                    pdfFiles[index] = File(newPath);
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error renaming file: $e')),
                  );
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete PDF'),
          content: const Text('Are you sure you want to delete this file?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final file = pdfFiles[index];
                try {
                  if (await file.exists()) {
                    await file.delete();
                  }
                  setState(() {
                    pdfFiles.removeAt(index);
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting file: $e')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Pdf Files",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: isMultiSelectMode
            ? [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: selectedIndexes.isEmpty ? null : shareSelected,
                  tooltip: 'Share Selected',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: selectedIndexes.isEmpty ? null : deleteSelected,
                  tooltip: 'Delete Selected',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: toggleMultiSelectMode,
                  tooltip: 'Cancel',
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  tooltip: 'Select Multiple',
                  onPressed: toggleMultiSelectMode,
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  tooltip: 'Go to Images Screen',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ImagesScreen()),
                    );
                  },
                ),
              ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: pdfFiles.isEmpty
            ? const Center(
                child: Text('No PDFs selected', style: TextStyle(fontSize: 24)),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3,
                ),
                itemCount: pdfFiles.length,
                itemBuilder: (context, index) {
                  String name = p.basenameWithoutExtension(
                    pdfFiles[index].path,
                  );
                  if (isMultiSelectMode) {
                    return InkWell(
                      onTap: () => toggleSelectIndex(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedIndexes.contains(index)
                                ? Colors.blue
                                : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: selectedIndexes.contains(index)
                              ? Colors.blue.withOpacity(0.3)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: selectedIndexes.contains(index),
                              onChanged: (_) => toggleSelectIndex(index),
                            ),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(fontSize: 23),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PdfViewScreen(file: pdfFiles[index]),
                          ),
                        );
                        if (result == true) {
                          setState(() {
                            pdfFiles.removeAt(index);
                          });
                        }
                      },
                      onLongPress: () => _showOptionsDialog(context, index),
                      child: Text(name, style: const TextStyle(fontSize: 23)),
                    );
                  }
                },
              ),
      ),
      floatingActionButton: isMultiSelectMode
          ? null
          : FloatingActionButton(
              onPressed: pickPdfs,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}
