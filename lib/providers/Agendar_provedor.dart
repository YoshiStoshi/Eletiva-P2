import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class ScheduleEntry {
  final String id;
  final String workoutName;
  final String dayOfWeek;
  final String time;
  final String instructor;
  final int spotsTotal;
  final int spotsAvailable;
  final bool isBooked;

  ScheduleEntry({
    required this.id,
    required this.workoutName,
    required this.dayOfWeek,
    required this.time,
    required this.instructor,
    required this.spotsTotal,
    required this.spotsAvailable,
    this.isBooked = false,
  });

  factory ScheduleEntry.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ScheduleEntry(
      id: doc.id,
      workoutName: d['workoutName'] ?? '',
      dayOfWeek: d['dayOfWeek'] ?? '',
      time: d['time'] ?? '',
      instructor: d['instructor'] ?? '',
      spotsTotal: d['spotsTotal'] ?? 0,
      spotsAvailable: d['spotsAvailable'] ?? 0,
      isBooked: d['isBooked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'workoutName': workoutName,
    'dayOfWeek': dayOfWeek,
    'time': time,
    'instructor': instructor,
    'spotsTotal': spotsTotal,
    'spotsAvailable': spotsAvailable,
    'isBooked': isBooked,
    'createdAt': FieldValue.serverTimestamp(),
    'uid': FirebaseService.uid,
  };
}

class ScheduleProvider extends ChangeNotifier {
  List<String> get days =>
      ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];

  // RF005 — Stream em tempo real por dia
  Stream<List<ScheduleEntry>> getEntriesStream(String day) =>
      FirebaseService.userCollection('agendamentos')
          .where('dayOfWeek', isEqualTo: day)
          .snapshots()
          .map((s) => s.docs.map((d) => ScheduleEntry.fromFirestore(d)).toList());

  // RF005 — Stream de inscrições ativas
  Stream<List<ScheduleEntry>> get myBookingsStream =>
      FirebaseService.userCollection('agendamentos')
          .where('isBooked', isEqualTo: true)
          .snapshots()
          .map((s) => s.docs.map((d) => ScheduleEntry.fromFirestore(d)).toList());

  // RF003 — Inserção na coleção agendamentos
  Future<String?> addEntry(ScheduleEntry entry) async {
    try {
      await FirebaseService.userCollection('agendamentos').add(entry.toMap());
      return null;
    } catch (e) { return 'Erro ao adicionar: $e'; }
  }

  // RF004 — Atualização: inscrição
  Future<String?> bookClass(String id) async {
    try {
      await FirebaseService.userCollection('agendamentos').doc(id).update({
        'isBooked': true,
        'spotsAvailable': FieldValue.increment(-1),
      });
      return null;
    } catch (e) { return 'Erro ao inscrever: $e'; }
  }

  // RF004 — Atualização: cancelamento
  Future<String?> cancelBooking(String id) async {
    try {
      await FirebaseService.userCollection('agendamentos').doc(id).update({
        'isBooked': false,
        'spotsAvailable': FieldValue.increment(1),
      });
      return null;
    } catch (e) { return 'Erro ao cancelar: $e'; }
  }

  // Seed inicial de aulas
  Future<void> seedInitialData() async {
    final snap = await FirebaseService.userCollection('agendamentos').limit(1).get();
    if (snap.docs.isNotEmpty) return;
    final aulas = [
      ScheduleEntry(id: '', workoutName: 'Jiu-Jitsu', dayOfWeek: 'Segunda', time: '20:00', instructor: 'Danilo', spotsTotal: 20, spotsAvailable: 8),
      ScheduleEntry(id: '', workoutName: 'Jiu-Jitsu', dayOfWeek: 'Quarta', time: '20:00', instructor: 'Danilo', spotsTotal: 20, spotsAvailable: 12),
    ];
    for (final a in aulas) {
      await FirebaseService.userCollection('agendamentos').add(a.toMap());
    }
  }
}
