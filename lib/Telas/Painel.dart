// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/Autentificacao.dart';
import '../providers/Treino_provedor.dart';
import '../providers/Planos_provedor.dart';
import '../providers/Agendar_provedor.dart';
import 'ApiExercicios.dart';
import 'Sobre.dart';

class Painel extends StatelessWidget {
  const Painel({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final workoutProvider = context.read<WorkoutProvider>();
    final scheduleProvider = context.read<ScheduleProvider>();
    final planProvider = context.read<PlanProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Boas-vindas
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE10600), Color(0xFF8B0000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${auth.name ?? 'Atleta'}! 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Bem-vindo(a) de volta ao Power House!',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.emoji_events, color: Colors.white, size: 40),
              ],
            ),
          ),
          SizedBox(height: 20),

          Text(
            'Resumo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),

          // RF005 — StreamBuilder para treinos
          Row(
            children: [
              Expanded(
                child: StreamBuilder<List<WorkoutModel>>(
                  stream: workoutProvider.workoutsStream,
                  builder: (context, snapshot) {
                    final total = snapshot.data?.length ?? 0;
                    return _cardResumo(
                      icon: Icons.fitness_center,
                      titulo: 'Treinos',
                      valor: '$total',
                      cor: Color(0xFFE10600),
                    );
                  },
                ),
              ),
              SizedBox(width: 12),
              // RF005 — StreamBuilder para agendamentos
              Expanded(
                child: StreamBuilder<List<ScheduleEntry>>(
                  stream: scheduleProvider.myBookingsStream,
                  builder: (context, snapshot) {
                    final total = snapshot.data?.length ?? 0;
                    return _cardResumo(
                      icon: Icons.calendar_today,
                      titulo: 'Aulas',
                      valor: '$total',
                      cor: Colors.blue,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              // RF005 — StreamBuilder para favoritos
              Expanded(
                child: StreamBuilder<List<WorkoutModel>>(
                  stream: workoutProvider.favoritesStream,
                  builder: (context, snapshot) {
                    final total = snapshot.data?.length ?? 0;
                    return _cardResumo(
                      icon: Icons.favorite,
                      titulo: 'Favoritos',
                      valor: '$total',
                      cor: Colors.pink,
                    );
                  },
                ),
              ),
              SizedBox(width: 12),
              // RF005 — StreamBuilder para matrículas
              Expanded(
                child: StreamBuilder<List<MatriculaModel>>(
                  stream: planProvider.matriculasStream,
                  builder: (context, snapshot) {
                    final ativos = snapshot.data
                            ?.where((m) => m.status == 'ativo')
                            .length ??
                        0;
                    return _cardResumo(
                      icon: Icons.credit_card,
                      titulo: 'Planos',
                      valor: '$ativos',
                      cor: Colors.amber,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          Text(
            'Acesso Rápido',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),

          // Atalhos
          Row(
            children: [
              Expanded(
                child: _cardAtalho(
                  context: context,
                  icon: Icons.sports_gymnastics,
                  titulo: 'Exercícios',
                  subtitulo: 'Biblioteca API',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ApiExercicios()),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _cardAtalho(
                  context: context,
                  icon: Icons.info_outline,
                  titulo: 'Sobre',
                  subtitulo: 'O projeto',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Sobre()),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _cardResumo({
    required IconData icon,
    required String titulo,
    required String valor,
    required Color cor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: cor, size: 20),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valor,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                titulo,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardAtalho({
    required BuildContext context,
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Color(0xFFE10600), size: 28),
            SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitulo,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
