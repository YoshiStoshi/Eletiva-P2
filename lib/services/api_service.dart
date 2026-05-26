// RF007 — Consumo de API REST pública (wger.de — exercícios)
import 'dart:convert';
import 'package:http/http.dart' as http;

class ExerciseModel {
  final int id;
  final String name;
  final String description;
  final String category;
  final String equipment;
  final String muscles;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.equipment,
    required this.muscles,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    final translations = (json['translations'] as List?) ?? [];
    final ptTranslation = translations.firstWhere(
      (t) => t['language'] == 2,
      orElse: () => translations.isNotEmpty ? translations.first : {},
    );

    String rawDesc = ptTranslation['description'] ?? json['description'] ?? '';
    rawDesc = rawDesc
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();

    return ExerciseModel(
      id: json['id'] ?? 0,
      name: ptTranslation['name'] ?? json['name'] ?? 'Exercício',
      description: rawDesc.isEmpty ? 'Sem descrição disponível.' : rawDesc,
      category: json['category']?['name'] ?? '',
      equipment: (json['equipment'] as List?)
              ?.map((e) => e['name'] as String)
              .join(', ') ??
          '',
      muscles: (json['muscles'] as List?)
              ?.map((m) => m['name_en'] as String)
              .join(', ') ??
          '',
    );
  }
}

class ApiService {
  static const String _base = 'https://wger.de/api/v2';

  // RF007 — Busca exercícios na API pública wger.de
  static Future<List<ExerciseModel>> fetchExercises({
    String query = '',
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final params = {
        'format': 'json',
        'language': '2',
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (query.isNotEmpty) 'name': query,
      };

      final uri =
          Uri.parse('$_base/exercise/').replace(queryParameters: params);
      final response =
          await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List? ?? [];
        return results
            .map((e) => ExerciseModel.fromJson(e))
            .where((e) => e.name.isNotEmpty)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
