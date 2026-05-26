// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/Autentificacao.dart';
import '../providers/Treino_provedor.dart';
import '../providers/Agendar_provedor.dart';
import 'Painel.dart';
import 'Treinos.dart';
import 'Agendamento.dart';
import 'Planos.dart';
import 'Pesquisa.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _indiceAtual = 0;

  final List<Widget> _telas = [
    Painel(),
    Treinos(),
    Agendamento(),
    Planos(),
    Pesquisa(),
  ];

  @override
  void initState() {
    super.initState();
    // Seed dados iniciais para o usuário
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<WorkoutProvider>().seedInitialData();
      await context.read<ScheduleProvider>().seedInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.fitness_center, color: Color(0xFFE10600), size: 22),
            SizedBox(width: 8),
            Text(
              'Power House GYM',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Sair — RF001
          IconButton(
            icon: Icon(Icons.logout, color: Colors.grey[400]),
            tooltip: 'Sair',
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Color(0xFF1A1A1A),
                  title: Text('Sair', style: TextStyle(color: Colors.white)),
                  content: Text(
                    'Deseja encerrar a sessão?',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Sair',
                          style: TextStyle(color: Color(0xFFE10600))),
                    ),
                  ],
                ),
              );
              if (confirmar == true) await auth.logout();
            },
          ),
        ],
      ),
      body: _telas[_indiceAtual],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Color(0xFF1A1A1A),
        indicatorColor: Color(0xFFE10600).withOpacity(0.2),
        selectedIndex: _indiceAtual,
        onDestinationSelected: (i) => setState(() => _indiceAtual = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFFE10600)),
            label: 'Painel',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined, color: Colors.grey),
            selectedIcon:
                Icon(Icons.fitness_center, color: Color(0xFFE10600)),
            label: 'Treinos',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined, color: Colors.grey),
            selectedIcon:
                Icon(Icons.calendar_today, color: Color(0xFFE10600)),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.credit_card, color: Color(0xFFE10600)),
            label: 'Planos',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.search, color: Color(0xFFE10600)),
            label: 'Pesquisa',
          ),
        ],
      ),
    );
  }
}
