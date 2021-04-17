import 'package:web/constants.dart';

class TextDisplay {
  static String shortenFilename(String inputText) {
    if (inputText.length <= Constants.maxFileName) {
      return inputText;
    }
    return '${inputText.substring(0, Constants.maxFileName - 3)}...';
  }
}
