import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zapx/zapx.dart';

void main() async {
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
  int fontNumber = 0;
  List<String> fontNames = [
    'Abel',
    'Aboreto',
    'Robot',
    'GochiHand',
    'BenchNine',
    'londRineOutline'
  ];
  String selectedFont = 'Abel';

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
                      child: Text(text, style: _getFontStyle(selectedFont)),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Edit Text: '),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            onChanged: (value) {
                              _updateText(value);
                            },
                            decoration: InputDecoration(
                                hintText: 'Enter Text',
                                enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        width: 2, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 2))),
                          ),
                        ),
                      ),
                    ],
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
                  Row(
                    children: [
                      const Text('Text Style:'),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: DropdownButton2(
                            isExpanded: true,
                            alignment: Alignment.topLeft,
                            buttonStyleData: ButtonStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(width: 2, color: Colors.grey),
                              ),
                            ),
                            underline: Text(
                              selectedFont.isEmpty
                                  ? 'Select FontStyle'
                                  : selectedFont,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis),
                            ).paddingOnly(left: 10),
                            items: const [
                              DropdownMenuItem(
                                value: 'Abel',
                                child: Text('Abel'),
                              ),
                              DropdownMenuItem(
                                value: 'Aboreto',
                                child: Text('Aboreto'),
                              ),
                              DropdownMenuItem(
                                value: 'Robot',
                                child: Text('Robot'),
                              ),
                              DropdownMenuItem(
                                value: 'GochiHand',
                                child: Text('GochiHand'),
                              ),
                              DropdownMenuItem(
                                value: 'BenchNine',
                                child: Text('BenchNine'),
                              ),
                              DropdownMenuItem(
                                value: 'londRineOutline',
                                child: Text('londRineOutline'),
                              )
                            ],
                            onChanged: (identifier) {
                              setState(() {
                                selectedFont = identifier!;
                              });
                            }),
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
              child: const Text('Select'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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

  TextStyle _getFontStyle(String selectedFont) {
    TextStyle style = GoogleFonts.aBeeZee(
        textStyle: TextStyle(
      fontSize: textSize,
      color: textColor,
    ));
    switch (selectedFont) {
      case 'Abel':
        style = GoogleFonts.abel(
            textStyle: TextStyle(
          fontSize: textSize,
          color: textColor,
        ));
        break;
      case 'Aberote':
        style = GoogleFonts.aboreto(
            textStyle: TextStyle(
          fontSize: textSize,
          color: textColor,
        ));
        break;
      case 'Robot':
        style = GoogleFonts.roboto(
            textStyle: TextStyle(
          fontSize: textSize,
          color: textColor,
        ));
        break;
      case 'GochiHand':
        style = GoogleFonts.gochiHand(
            textStyle: TextStyle(
          fontSize: textSize,
          color: textColor,
        ));
        break;
      case 'BenchNine':
        style = GoogleFonts.benchNine(
            textStyle: TextStyle(
          fontSize: textSize,
          color: textColor,
        ));
        break;
      case 'londRineOutline':
        style = GoogleFonts.londrinaOutline(
            textStyle: TextStyle(
          fontSize: textSize,
          color: textColor,
        ));
        break;
      default:
        style = style;
    }
    return style;
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
