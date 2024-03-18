import 'package:flutter/material.dart';

import '../model/text_chanage.dart';

class TextContainerProvider extends ChangeNotifier {
  List<TextChange> _textContainerList = [TextChange(text: 'Rajkumar', textColor: Colors.amber, textSize: 20, position: Offset(0, 0))];

  List<TextChange> get getTextContainerList => [..._textContainerList];

  void addTextConatiner(TextChange instance) {
    _textContainerList.add(instance);
    notifyListeners();
  }
}
