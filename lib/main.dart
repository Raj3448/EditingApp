import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TextEditorScreen(),
    );
  }
}

class TextEditorScreen extends StatefulWidget {
  @override
  _TextEditorScreenState createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  String text = 'Edit me!';
  Color textColor = Colors.black;
  double textSize = 20.0;
  String fontFamily = '';
  Offset position = const Offset(0, 0);
  List<TextChange> history = [];
  int historyIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('Text Editor'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: canUndo() ? undo : null,
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: canRedo() ? redo : null,
                ),
              ],
            ),
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  position += details.delta;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: Colors.white,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Stack(
                  children: [
                    Positioned(
                      left: position.dx,
                      top: position.dy,
                      child: Text(
                        text,
                        style: TextStyle(
                          fontFamily: '',
                          color: textColor,
                          fontSize: textSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      _updateText(value);
                    },
                    decoration: InputDecoration(labelText: 'Text'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Text Color:'),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          _selectColor(context);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: textColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Text Size:'),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Slider(
                          value: textSize,
                          min: 10,
                          max: 50,
                          onChanged: (value) {
                            _updateTextSize(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void undo() {
    if (canUndo()) {
      TextChange change = history[historyIndex];
      setState(() {
        text = change.text;
        textColor = change.textColor;
        textSize = change.textSize;
        position = change.position;
        historyIndex--;
      });
    }
  }

  void redo() {
    if (canRedo()) {
      historyIndex++;
      TextChange change = history[historyIndex];
      setState(() {
        text = change.text;
        textColor = change.textColor;
        textSize = change.textSize;
        position = change.position;
      });
    }
  }

  bool canUndo() {
    return historyIndex > 0;
  }

  bool canRedo() {
    return historyIndex < history.length - 1;
  }

  void _updateText(String value) {
    setState(() {
      history.add(TextChange(
        text: text,
        textColor: textColor,
        textSize: textSize,
        position: position,
      ));
      historyIndex = history.length - 1;
      text = value;
    });
  }

  void _updateTextSize(double value) {
    setState(() {
      history.add(TextChange(
        text: text,
        textColor: textColor,
        textSize: textSize,
        position: position,
      ));
      historyIndex = history.length - 1;
      textSize = value;
    });
  }

  void _selectColor(BuildContext context) async {
    Color newColor = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Text Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: textColor,
              onColorChanged: (color) {
                setState(() {
                  history.add(TextChange(
                    text: text,
                    textColor: textColor,
                    textSize: textSize,
                    position: position,
                  ));
                  historyIndex = history.length - 1;
                  textColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(textColor);
              },
              child: Text('Select'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (newColor != null) {
      setState(() {
        textColor = newColor;
      });
    }
  }
}

class TextChange {
  final String text;
  final Color textColor;
  final double textSize;
  final Offset position;

  TextChange({
    required this.text,
    required this.textColor,
    required this.textSize,
    required this.position,
  });
}
