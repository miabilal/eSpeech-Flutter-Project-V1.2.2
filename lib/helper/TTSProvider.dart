import 'package:espeech/model/tts.dart';
import 'package:flutter/cupertino.dart';

class TTSProvider with ChangeNotifier {
  List<TTS> ttsList = [];

  get getTTSList => ttsList;

  setTtsList(List<TTS>? ttsList1) {
    ttsList = ttsList1!;
    notifyListeners();
  }

  clearTtsList() {
    ttsList.clear();
    notifyListeners();
  }

  removeIdTtsList(String id) {
    ttsList.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
