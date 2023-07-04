import 'dart:convert';
import 'package:http/http.dart' as http;

class WordsApi {
  static const baseUrl = 'https://wordsapiv1.p.rapidapi.com/words/';
  static const apiKey = '92c8cefd17msh77d65ab088456d5p1895f1jsnc22850cb6e8f';
  static const apiHost = 'wordsapiv1.p.rapidapi.com';

  Future<String> fetchPronunciation(String word) async {
    final url = Uri.parse('$baseUrl$word/pronunciation');

    final response = await http.get(
      url,
      headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': apiHost,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final pronunciation = jsonData['pronunciation']['all'] as String;
      return pronunciation;
    } else {
      throw Exception('Failed to fetch pronunciation');
    }
  }

  Future<String> fetchMeaning(String word) async {
    final url = Uri.parse('$baseUrl$word/definitions');

    final response = await http.get(
      url,
      headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': apiHost,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final definitions = jsonData['definitions'] as List<dynamic>;
      if (definitions.isNotEmpty) {
        final definition = definitions[0]['definition'] as String;
        return definition;
      }
    }

    throw Exception('Failed to fetch meaning');
  }
}
