import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeech {
  FlutterTts flutterTts = FlutterTts();
  Future<void> speak(String text) async {
    String language = 'th-TH';
    await flutterTts.setLanguage(language);
    await flutterTts.speak(text);
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }

}
