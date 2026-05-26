import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class PlanModel {
  final String id;
  final String name;
  final double monthlyPrice;
  final double quarterlyPrice;
  final double yearlyPrice;
  final List<String> benefits;
  final bool isHighlighted;
  final String badge;

  PlanModel({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.quarterlyPrice,
    required this.yearlyPrice,
    required this.benefits,
    this.isHighlighted = false,
    this.badge = '',
  });
}

class MatriculaModel {
  final String id;
  final String planName;
  final String period;
  final double price;
  final String status;

  MatriculaModel({
    required this.id,
    required this.planName,
    required this.period,
    required this.price,
    required this.status,
  });

  factory MatriculaModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MatriculaModel(
      id: doc.id,
      planName: d['planName'] ?? '',
      period: d['period'] ?? '',
      price: (d['price'] ?? 0).toDouble(),
      status: d['status'] ?? 'ativo',
    );
  }

  Map<String, dynamic> toMap() => {
    'planName': planName,
    'period': period,
    'price': price,
    'status': status,
    'createdAt': FieldValue.serverTimestamp(),
    'uid': FirebaseService.uid,
  };
}

class PlanProvider extends ChangeNotifier {
  String _selectedPeriod = 'Mensal';
  String? _selectedPlanId;

  String get selectedPeriod => _selectedPeriod;
  String? get selectedPlanId => _selectedPlanId;
  List<String> get periods => ['Mensal', 'Trimestral', 'Anual'];

  final List<PlanModel> _plans = [
    PlanModel(id: 'basic', name: 'Básico', monthlyPrice: 89.90, quarterlyPrice: 79.90, yearlyPrice: 69.90,
      benefits: ['Acesso à área de musculação', 'Horário comercial (6h–22h)', 'Vestiário completo', 'Avaliação física inicial']),
    PlanModel(id: 'pro', name: 'Pro', monthlyPrice: 129.90, quarterlyPrice: 109.90, yearlyPrice: 89.90,
      benefits: ['Tudo do plano Básico', 'Aulas coletivas ilimitadas', 'Acesso 24h', 'App de treinos exclusivo', '1 sessão de personal/mês'],
      isHighlighted: true, badge: 'Mais Popular'),
    PlanModel(id: 'elite', name: 'Power', monthlyPrice: 249.90, quarterlyPrice: 219.90, yearlyPrice: 189.90,
      benefits: ['Tudo do plano Pro', 'Personal trainer 2x/semana', 'Consulta nutricional mensal', 'Acesso ao spa e sauna', 'Estacionamento gratuito', 'Convidado grátis às sextas'],
      badge: 'Promoção'),
  ];

  List<PlanModel> get plans => List.unmodifiable(_plans);

  double getPriceForPlan(PlanModel plan) {
    switch (_selectedPeriod) {
      case 'Trimestral': return plan.quarterlyPrice;
      case 'Anual': return plan.yearlyPrice;
      default: return plan.monthlyPrice;
    }
  }

  void selectPeriod(String period) { _selectedPeriod = period; notifyListeners(); }
  void selectPlan(String planId) { _selectedPlanId = planId; notifyListeners(); }

  // RF003 — Inserção na coleção matriculas
  Future<String?> subscribePlan(PlanModel plan) async {
    try {
      final m = MatriculaModel(id: '', planName: plan.name, period: _selectedPeriod,
          price: getPriceForPlan(plan), status: 'ativo');
      await FirebaseService.userCollection('matriculas').add(m.toMap());
      return null;
    } catch (e) { return 'Erro ao realizar matrícula: $e'; }
  }

  // RF004 — Atualização na coleção matriculas
  Future<String?> updateMatricula(String id, String newStatus) async {
    try {
      await FirebaseService.userCollection('matriculas').doc(id).update({'status': newStatus});
      return null;
    } catch (e) { return 'Erro ao atualizar: $e'; }
  }

  // RF005 — Stream em tempo real de matrículas
  Stream<List<MatriculaModel>> get matriculasStream =>
      FirebaseService.userCollection('matriculas')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map((d) => MatriculaModel.fromFirestore(d)).toList());
}
