import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class WorkoutModel {
  final String id;
  final String name;
  final String category;
  final String duration;
  final String difficulty;
  final String description;
  final String icon;
  final bool isFavorite;
  final Timestamp? createdAt;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.category,
    required this.duration,
    required this.difficulty,
    required this.description,
    required this.icon,
    this.isFavorite = false,
    this.createdAt,
  });

  factory WorkoutModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WorkoutModel(
      id: doc.id,
      name: d['name'] ?? '',
      category: d['category'] ?? '',
      duration: d['duration'] ?? '',
      difficulty: d['difficulty'] ?? '',
      description: d['description'] ?? '',
      icon: d['icon'] ?? '💪',
      isFavorite: d['isFavorite'] ?? false,
      createdAt: d['createdAt'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category,
    'duration': duration,
    'difficulty': difficulty,
    'description': description,
    'icon': icon,
    'isFavorite': isFavorite,
    'nameLower': name.toLowerCase(),
    'createdAt': FieldValue.serverTimestamp(),
    'uid': FirebaseService.uid,
  };
}

class WorkoutProvider extends ChangeNotifier {
  // RF005 — Stream em tempo real
  Stream<List<WorkoutModel>> get workoutsStream =>
      FirebaseService.userCollection('treinos')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map((d) => WorkoutModel.fromFirestore(d)).toList());

  Stream<List<WorkoutModel>> get favoritesStream =>
      FirebaseService.userCollection('treinos')
          .where('isFavorite', isEqualTo: true)
          .snapshots()
          .map((s) => s.docs.map((d) => WorkoutModel.fromFirestore(d)).toList());

  // RF006 — Pesquisa case-insensitive com ordenação
  Stream<List<WorkoutModel>> searchStream(String query, String orderBy) {
    Query ref = FirebaseService.userCollection('treinos');
    if (query.isNotEmpty) {
      final lower = query.toLowerCase();
      ref = ref
          .where('nameLower', isGreaterThanOrEqualTo: lower)
          .where('nameLower', isLessThanOrEqualTo: '$lower\uf8ff');
    }
    switch (orderBy) {
      case 'Nome A-Z': ref = ref.orderBy('nameLower'); break;
      case 'Mais recente': ref = ref.orderBy('createdAt', descending: true); break;
      case 'Dificuldade': ref = ref.orderBy('difficulty'); break;
    }
    return ref.snapshots()
        .map((s) => s.docs.map((d) => WorkoutModel.fromFirestore(d)).toList());
  }

  List<String> get categories => ['Todos', 'Musculação', 'Coletiva', 'Personal'];
  List<String> get orderOptions => ['Nome A-Z', 'Mais recente', 'Dificuldade'];

  // RF003 — Inserção na coleção treinos
  Future<String?> addWorkout(WorkoutModel w) async {
    try {
      await FirebaseService.userCollection('treinos').add(w.toMap());
      return null;
    } catch (e) { return 'Erro ao adicionar: $e'; }
  }

  // RF004 — Atualização na coleção treinos
  Future<String?> updateWorkout(String id, Map<String, dynamic> data) async {
    try {
      if (data.containsKey('name')) {
        data['nameLower'] = (data['name'] as String).toLowerCase();
      }
      await FirebaseService.userCollection('treinos').doc(id).update(data);
      return null;
    } catch (e) { return 'Erro ao atualizar: $e'; }
  }

  Future<String?> toggleFavorite(String id, bool current) =>
      updateWorkout(id, {'isFavorite': !current});

  Future<String?> deleteWorkout(String id) async {
    try {
      await FirebaseService.userCollection('treinos').doc(id).delete();
      return null;
    } catch (e) { return 'Erro ao excluir: $e'; }
  }

  // Seed inicial para novos usuários
  Future<void> seedInitialData() async {
    final snap = await FirebaseService.userCollection('treinos').limit(1).get();
    if (snap.docs.isNotEmpty) return;
    final treinos = [
      WorkoutModel(id: '', name: 'Musculação Upper Body', category: 'Musculação', duration: '60 min', difficulty: 'Intermediário', description: 'Treino focado em peitoral, costas, ombros e braços com exercícios compostos e isolados.', icon: '💪'),
      WorkoutModel(id: '', name: 'Jiu-Jitsu', category: 'Coletiva', duration: '120 min', difficulty: 'Avançado', description: 'Treinamento completo de Jiu-Jitsu com técnicas de posição, transição e finalização.', icon: '🥋'),
      WorkoutModel(id: '', name: 'Musculação Lower Body', category: 'Musculação', duration: '60 min', difficulty: 'Intermediário', description: 'Treino de pernas completo: agachamento, leg press, cadeira extensora, rosca femoral e panturrilha.', icon: '🦵'),
      WorkoutModel(id: '', name: 'Personal Training', category: 'Personal', duration: '45 min', difficulty: 'Personalizado', description: 'Treino personalizado com acompanhamento individual de personal trainer certificado.', icon: '🏆'),
    ];
    for (final t in treinos) {
      await FirebaseService.userCollection('treinos').add(t.toMap());
    }
  }
}
