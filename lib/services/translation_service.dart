import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  final _modelManager = OnDeviceTranslatorModelManager();

  Future<String> translate(
      String text,
      TranslateLanguage from,
      TranslateLanguage to,
      ) async {
    for (final lang in [from, to]) {
      final ready = await _modelManager.isModelDownloaded(lang.bcpCode);
      if (!ready) await _modelManager.downloadModel(lang.bcpCode);
    }
    final translator = OnDeviceTranslator(
      sourceLanguage: from,
      targetLanguage: to,
    );
    try {
      return await translator.translateText(text);
    } finally {
      await translator.close();
    }
  }
}