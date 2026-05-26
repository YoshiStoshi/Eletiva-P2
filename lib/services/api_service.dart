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
    final translations = (json['translations'] as List<dynamic>?) ?? [];
    final ptTranslation = translations.cast<Map<String, dynamic>?>().firstWhere(
          (t) => t != null && t['language'] == 2,
          orElse: () => translations.isNotEmpty
              ? translations.first as Map<String, dynamic>
              : {},
        );

    String rawDesc = '';
    if (ptTranslation is Map<String, dynamic>) {
      rawDesc = ptTranslation['description'] ?? '';
    }
    rawDesc = rawDesc.isEmpty ? json['description'] ?? '' : rawDesc;
    rawDesc = rawDesc
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();

    String name = '';
    if (ptTranslation is Map<String, dynamic>) {
      name = ptTranslation['name'] ?? '';
    }
    name = name.isEmpty ? json['name'] ?? 'Exercício' : name;

    final categoryValue = json['category'];
    String category = '';
    if (categoryValue is Map<String, dynamic>) {
      category = categoryValue['name'] ?? '';
    } else if (categoryValue != null) {
      category = categoryValue.toString();
    }

    String equipment = '';
    final equipmentValue = json['equipment'];
    if (equipmentValue is List) {
      equipment = equipmentValue.map((e) => e.toString()).join(', ');
    }

    String muscles = '';
    final musclesValue = json['muscles'];
    if (musclesValue is List) {
      muscles = musclesValue.map((m) => m.toString()).join(', ');
    }

    return ExerciseModel(
      id: json['id'] ?? 0,
      name: name,
      description: rawDesc.isEmpty ? 'Sem descrição disponível.' : rawDesc,
      category: category,
      equipment: equipment,
      muscles: muscles,
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
    final params = {
      'format': 'json',
      'language': '2',
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (query.isNotEmpty) 'name': query,
    };

    final uri = Uri.parse('$_base/exercise/').replace(queryParameters: params);
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
          'API retornou status ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final results = data['results'] as List? ?? [];
    return results
        .map((e) => ExerciseModel.fromJson(e))
        .where((e) => e.name.isNotEmpty)
        .toList();
  }
}
