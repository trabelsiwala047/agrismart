import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../services/translation_service.dart';

class TranslationProvider extends ChangeNotifier {
  final _service = TranslationService();

  TranslateLanguage from = TranslateLanguage.french;
  TranslateLanguage to = TranslateLanguage.arabic;
  String result = '';
  bool loading = false;
  String? error;

  void swap() {
    final tmp = from;
    from = to;
    to = tmp;
    result = '';
    notifyListeners();
  }

  Future<void> translate(String text) async {
    if (text.trim().isEmpty) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      result = await _service.translate(text, from, to);
    } catch (e) {
      error = 'Erreur de traduction. Vérifiez la connexion (1er usage).';
    }
    loading = false;
    notifyListeners();
  }
}