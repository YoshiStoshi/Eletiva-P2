// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

class Sobre extends StatelessWidget {
  const Sobre({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Sobre', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/logo.jpg',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color(0xFFE10600),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                      Icon(Icons.fitness_center, color: Colors.white, size: 50),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Power House GYM',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Versão Beta',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            SizedBox(height: 32),

            // Requisitos atendidos
            _secao('✅ Requisitos Atendidos'),
            _itemRequisito(
                'RF001', 'Login + recuperação via Firebase Authentication'),
            _itemRequisito(
                'RF002', 'Cadastro Firebase Auth + campos no Firestore'),
            _itemRequisito('RF003',
                'Inserção em 4 coleções: usuarios, treinos, agendamentos, matriculas'),
            _itemRequisito(
                'RF004', 'Atualização em treinos, agendamentos e matriculas'),
            _itemRequisito('RF005',
                'StreamBuilder + ListView/GridView em tempo real — 2+ coleções'),
            _itemRequisito('RF006',
                'Tela exclusiva de pesquisa com ordenação e case-insensitive'),
            _itemRequisito('RF007', 'Consumo de API REST pública (wger.de)'),
            SizedBox(height: 24),

            // Tecnologias
            _secao('🛠️ Tecnologias'),
            _itemTech(Icons.flutter_dash, 'Flutter SDK', Colors.blue),
            _itemTech(
                Icons.local_fire_department, 'Firebase Auth', Colors.orange),
            _itemTech(Icons.storage, 'Cloud Firestore', Colors.orange),
            _itemTech(Icons.cloud, 'Firebase Hosting', Colors.orange),
            _itemTech(Icons.http, 'API REST (wger.de)', Colors.green),
            _itemTech(Icons.account_tree, 'Provider (State Management)',
                Colors.purple),
            SizedBox(height: 24),

            // Equipe
            _secao('👥 Equipe'),
            _cardPessoa('Rodrigo de Azevedo Junior', 'Desenvolvedor'),
            _cardPessoa('Davi Sousa Cirilo', 'Desenvolvedor'),
            SizedBox(height: 24),

            // Informações acadêmicas
            _secao('🏫 Informações Acadêmicas'),
            _infoAcademica('Disciplina', 'Dispositivos Moveis'),
            _infoAcademica('Instituição', 'FATEC Ribeirão Preto'),
            _infoAcademica('Professor', 'Prof. Rodrigo Plotze'),
            _infoAcademica('Semestre', '4º Semestre / 2026'),
            SizedBox(height: 32),

            Text(
              '© 2026 Power House Fitness GYM',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _secao(String titulo) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          titulo,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _itemRequisito(String rf, String descricao) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Color(0xFFE10600).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              rf,
              style: TextStyle(
                color: Color(0xFFE10600),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              descricao,
              style: TextStyle(color: Colors.grey[300], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemTech(IconData icon, String nome, Color cor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: cor, size: 20),
          SizedBox(width: 12),
          Text(nome, style: TextStyle(color: Colors.grey[300], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _cardPessoa(String nome, String cargo) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFE10600).withOpacity(0.2),
            child: Icon(Icons.person, color: Color(0xFFE10600)),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                cargo,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoAcademica(String label, String valor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
