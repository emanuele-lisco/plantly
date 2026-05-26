import 'package:translator/translator.dart';

class PlantTranslationService {
  PlantTranslationService({GoogleTranslator? translator})
      : _translator = translator ?? GoogleTranslator();

  final GoogleTranslator _translator;

  Future<String> translateEnToIt(String text) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty) return text;

    try {
      final translation = await _translator.translate(
        cleanText,
        from: 'en',
        to: 'it',
      );

      final translated = translation.text.trim();
      return translated.isEmpty ? text : translated;
    } catch (_) {
      return text;
    }
  }
}