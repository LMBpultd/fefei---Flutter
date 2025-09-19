import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import 'full_image_screen.dart';
import 'pdf_screen.dart';  // <-- PDF screen import

class ImagesScreen extends StatefulWidget {
  const ImagesScreen({super.key});

  @override
  State<ImagesScreen> createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen> {
  bool? _isDark;
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  // Multi-select mode variables
  bool _isMultiSelectMode = false;
  final Set<File> _selectedImages = {};

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  Future<void> _loadSavedImages() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync();
    final images = files.whereType<File>().where((file) {
      final ext = p.extension(file.path).toLowerCase().replaceFirst('.', '');
      return ['png', 'jpg', 'jpeg', 'gif', 'bmp'].contains(ext);
    }).toList();

    if (!mounted) return;

    setState(() {
      _images = images;
    });
  }

  String _generateUniqueFileName(String dirPath, String originalName) {
    String nameWithoutExt = p.basenameWithoutExtension(originalName);
    String ext = p.extension(originalName);
    String newName = originalName;
    int count = 1;
    while (File(p.join(dirPath, newName)).existsSync()) {
      newName = '$nameWithoutExt($count)$ext';
      count++;
    }
    return newName;
  }

  Future<void> _pickAndSaveImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    // ignore: unnecessary_null_comparison
    if (pickedFiles == null || pickedFiles.isEmpty) return;

    final appDir = await getApplicationDocumentsDirectory();
    if (!mounted) return;

    for (var picked in pickedFiles) {
      final fileName = picked.name;
      final uniqueName = _generateUniqueFileName(appDir.path, fileName);

      final savedFile = await File(picked.path).copy(p.join(appDir.path, uniqueName));
      if (!mounted) return;

      setState(() {
        _images.add(savedFile);
      });
    }
  }

  void _toggleTheme() {
    setState(() {
      if (_isDark == null) {
        final brightness = MediaQuery.of(context).platformBrightness;
        _isDark = brightness != Brightness.dark;
      } else {
        _isDark = !_isDark!;
      }
    });
  }

  Future<void> _showImageOptions(File image) async {
    final name = _getNameWithoutExtension(image);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(name),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Rename',
                onPressed: () {
                  Navigator.pop(context);
                  _renameImage(image);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete',
                onPressed: () {
                  Navigator.pop(context);
                  _confirmDeleteImage(image);
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Share',
                onPressed: () {
                  Navigator.pop(context);
                  Share.shareXFiles([XFile(image.path)]);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _renameImage(File image) async {
    final oldName = _getNameWithoutExtension(image);
    final ext = p.extension(image.path);

    final controller = TextEditingController(text: oldName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Image'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'New name without extension',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context, null),
            ),
            TextButton(
              child: const Text('Rename'),
              onPressed: () {
                final input = controller.text.trim();
                if (input.isNotEmpty) {
                  Navigator.pop(context, input);
                }
              },
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (newName == null || newName.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();
    if (!mounted) return;

    final newPath = p.join(dir.path, '$newName$ext');

    if (File(newPath).existsSync()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File with this name already exists')),
      );
      return;
    }

    final renamedFile = await image.rename(newPath);
    if (!mounted) return;

    setState(() {
      _images[_images.indexOf(image)] = renamedFile;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Renamed to $newName$ext')),
    );
  }

  Future<void> _confirmDeleteImage(File image) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image?'),
        content: Text(
          'Are you sure you want to delete "${_getNameWithoutExtension(image)}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteImage(image);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted')),
      );
    }
  }

  Future<void> _deleteImage(File image) async {
    await image.delete();

    if (!mounted) return;

    setState(() {
      _images.remove(image);
      _selectedImages.remove(image);
      if (_selectedImages.isEmpty) {
        _toggleMultiSelectMode(false);
      }
    });
  }

  String _getNameWithoutExtension(File file) {
    final name = p.basename(file.path);
    return p.basenameWithoutExtension(name);
  }

  void _openFullImage(File image) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => FullImageScreen(image: image)),
    );

    if (deleted == true && mounted) {
      setState(() {
        _images.remove(image);
      });
    }
  }

  // Toggle multi-select mode
  void _toggleMultiSelectMode([bool? enable]) {
    setState(() {
      if (enable != null) {
        _isMultiSelectMode = enable;
      } else {
        _isMultiSelectMode = !_isMultiSelectMode;
      }
      if (!_isMultiSelectMode) {
        _selectedImages.clear();
      }
    });
  }

  void _onImageTapMultiSelect(File image) {
    setState(() {
      if (_selectedImages.contains(image)) {
        _selectedImages.remove(image);
        if (_selectedImages.isEmpty) {
          _toggleMultiSelectMode(false);
        }
      } else {
        _selectedImages.add(image);
      }
    });
  }

  // Delete selected images
  Future<void> _deleteSelectedImages() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Images?'),
        content: Text('Are you sure you want to delete ${_selectedImages.length} images?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    for (var img in _selectedImages.toList()) {
      await img.delete();
      _images.remove(img);
    }

    setState(() {
      _selectedImages.clear();
      _isMultiSelectMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected images deleted')),
    );
  }

  // Share selected images
  void _shareSelectedImages() {
    if (_selectedImages.isEmpty) return;
    Share.shareXFiles(_selectedImages.map((file) => XFile(file.path)).toList());
  }

  @override
  Widget build(BuildContext context) {
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = _isDark ?? (systemBrightness == Brightness.dark);

    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final appBarColor = isDarkMode ? Colors.black : Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: GestureDetector(
          onLongPress: _toggleTheme,
          child: const Text(
            "Images",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          if (_isMultiSelectMode) ...[
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Selected',
              onPressed: _selectedImages.isEmpty ? null : _deleteSelectedImages,
              color: _selectedImages.isEmpty ? Colors.grey : Colors.white,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share Selected',
              onPressed: _selectedImages.isEmpty ? null : _shareSelectedImages,
              color: _selectedImages.isEmpty ? Colors.grey : Colors.white,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel Selection',
              onPressed: () => _toggleMultiSelectMode(false),
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Go to PDF Screen',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PdfScreen()),
                );
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              tooltip: 'Select Multiple',
              onPressed: () => _toggleMultiSelectMode(true),
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Go to PDF Screen',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PdfScreen()),
                );
              },
            ),
          ]
        ],
      ),
      body: _images.isEmpty
          ? Center(
              child: Text(
                'No images uploaded',
                style: TextStyle(fontSize: 24, color: textColor),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: _images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  final image = _images[index];
                  final isSelected = _selectedImages.contains(image);

                  return GestureDetector(
                    onTap: () {
                      if (_isMultiSelectMode) {
                        _onImageTapMultiSelect(image);
                      } else {
                        _openFullImage(image);
                      }
                    },
                    onLongPress: () {
                      if (!_isMultiSelectMode) {
                        _toggleMultiSelectMode(true);
                        _onImageTapMultiSelect(image);
                      } else {
                        _showImageOptions(image);
                      }
                    },
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.file(image, fit: BoxFit.cover),
                        ),
                        if (_isMultiSelectMode)
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Checkbox(
                              value: isSelected,
                              onChanged: (val) {
                                _onImageTapMultiSelect(image);
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndSaveImages,
        backgroundColor: const Color.fromARGB(255, 0, 55, 255),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
