import 'package:flutter/material.dart';
import 'screens/images_screen.dart';
import 'screens/pdf_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Documents',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Text contents
  String _titleText = 'My Documents';
  String _paragraphText = 'Long press to add your own datas';

  // Font sizes
  double _titleFontSize = 85;
  double _paragraphFontSize = 25;

  // Editing states
  bool _isEditingTitle = false;
  bool _isEditingParagraph = false;

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _paragraphController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = _titleText;
    _paragraphController.text = _paragraphText;
  }

  void _startEditingTitle() {
    setState(() {
      _isEditingTitle = true;
      _titleController.text = _titleText;
    });
  }

  void _saveEditedTitle() {
    setState(() {
      _titleText = _titleController.text;
      _isEditingTitle = false;
    });
  }

  void _startEditingParagraph() {
    setState(() {
      _isEditingParagraph = true;
      _paragraphController.text = _paragraphText;
    });
  }

  void _saveEditedParagraph() {
    setState(() {
      _paragraphText = _paragraphController.text;
      _isEditingParagraph = false;
    });
  }

  // Method to discard changes and revert to original text
  void _discardChanges() {
    setState(() {
      _titleController.text = _titleText;
      _paragraphController.text = _paragraphText;
      _isEditingTitle = false;
      _isEditingParagraph = false;
    });
  }

  Future<void> _showFontSizeDialog({
    required double currentFontSize,
    required Function(double) onFontSizeChanged,
  }) async {
    double tempFontSize = currentFontSize;
    final TextEditingController fontSizeController = TextEditingController(
      text: tempFontSize.toStringAsFixed(0),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Font Size'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            void updateFontSizeFromText(String value) {
              final parsed = double.tryParse(value);
              if (parsed != null && parsed >= 10 && parsed <= 120) {
                tempFontSize = parsed;
                onFontSizeChanged(tempFontSize);
                setStateDialog(() {}); // update slider and preview text
              }
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  min: 10,
                  max: 120,
                  divisions: 110,
                  label: tempFontSize.toStringAsFixed(0),
                  value: tempFontSize,
                  onChanged: (value) {
                    setStateDialog(() {
                      tempFontSize = value;
                      fontSizeController.text = value.toStringAsFixed(0);
                      onFontSizeChanged(tempFontSize);
                    });
                  },
                ),
                TextField(
                  controller: fontSizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Font Size',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: updateFontSizeFromText,
                ),
                const SizedBox(height: 10),
                Text(
                  '${tempFontSize.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: tempFontSize),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(TextTheme textTheme) {
    if (_isEditingTitle) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: _titleController,
            maxLines: 1,
            autofocus: true,
            cursorColor: Theme.of(context).colorScheme.primary,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _titleFontSize,
              fontWeight: FontWeight.bold,
              color: textTheme.headlineLarge?.color,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _saveEditedTitle,
                child: const Text('Save'),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: _discardChanges, // Add this to discard changes
                child: const Text('Exit'),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: () {
                  _showFontSizeDialog(
                    currentFontSize: _titleFontSize,
                    onFontSizeChanged: (newSize) {
                      setState(() {
                        _titleFontSize = newSize;
                      });
                    },
                  );
                },
                child: Text('${_titleFontSize.toStringAsFixed(0)}'),
              ),
            ],
          ),
        ],
      );
    } else {
      return GestureDetector(
        onLongPress: _startEditingTitle,
        child: Text(
          _titleText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _titleFontSize,
            fontWeight: FontWeight.bold,
            color: textTheme.headlineLarge?.color,
          ),
        ),
      );
    }
  }

  Widget _buildParagraphSection(TextTheme textTheme) {
    if (_isEditingParagraph) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _paragraphController,
            maxLines: null,
            autofocus: true,
            cursorColor: Theme.of(context).colorScheme.primary,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: _paragraphFontSize,
              color: textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _saveEditedParagraph,
                child: const Text('Save'),
              ),

              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: () {
                  _showFontSizeDialog(
                    currentFontSize: _paragraphFontSize,
                    onFontSizeChanged: (newSize) {
                      setState(() {
                        _paragraphFontSize = newSize;
                      });
                    },
                  );
                },
                child: Text('${_paragraphFontSize.toStringAsFixed(0)}'),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: _discardChanges, // Add this to discard changes
                child: const Text('Exit'),
              ),
            ],
          ),
        ],
      );
    } else {
      return GestureDetector(
        onLongPress: _startEditingParagraph,
        child: Container(
          width: double.infinity,
          child: Text(
            _paragraphText,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: _paragraphFontSize,
              color: textTheme.bodyLarge?.color,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTitleSection(textTheme),
                const SizedBox(height: 40),
                _buildParagraphSection(textTheme),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: SizedBox(
        height: 60,
        width: double.infinity,
        child: Row(
          children: [
            SizedBox(width: screenWidth * 0.06),
            SizedBox(
              width: screenWidth * 0.4,
              height: 50,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 30),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ImagesScreen(),
                    ),
                  );
                },
                child: const Text("Images"),
              ),
            ),
            SizedBox(width: screenWidth * 0.07),
            SizedBox(
              width: screenWidth * 0.4,
              height: 50,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 30),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PdfScreen()),
                  );
                },
                child: const Text("Pdf"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
