// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/Treino_provedor.dart';

class Pesquisa extends StatefulWidget {
  const Pesquisa({super.key});

  @override
  State<Pesquisa> createState() => _PesquisaState();
}

class _PesquisaState extends State<Pesquisa> {
  final _txtBusca = TextEditingController();
  String _ordenacao = 'Nome A-Z';
  String _termoBusca = '';

  @override
  void dispose() {
    _txtBusca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutProvider>();

    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: Column(
        children: [
          // Cabeçalho de pesquisa
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pesquisar Treinos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),

                // RF006 — Campo de pesquisa exclusivo
                TextField(
                  controller: _txtBusca,
                  style: TextStyle(color: Colors.white),
                  onChanged: (v) => setState(() => _termoBusca = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'Digite o nome do treino...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon:
                        Icon(Icons.search, color: Color(0xFFE10600)),
                    suffixIcon: _termoBusca.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _txtBusca.clear();
                              setState(() => _termoBusca = '');
                            },
                          )
                        : null,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFE10600)),
                    ),
                    filled: true,
                    fillColor: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 12),

                // RF006 — Ordenação dos resultados
                Row(
                  children: [
                    Text(
                      'Ordenar por:',
                      style:
                          TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: provider.orderOptions.map((op) {
                            final sel = _ordenacao == op;
                            return Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(op),
                                selected: sel,
                                onSelected: (_) =>
                                    setState(() => _ordenacao = op),
                                backgroundColor: Color(0xFF1A1A1A),
                                selectedColor:
                                    Color(0xFFE10600).withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: sel
                                      ? Color(0xFFE10600)
                                      : Colors.grey[400],
                                  fontSize: 12,
                                ),
                                side: BorderSide(
                                  color: sel
                                      ? Color(0xFFE10600)
                                      : Colors.grey[700]!,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),
          ),

          // RF006 — StreamBuilder com pesquisa case-insensitive
          Expanded(
            child: StreamBuilder<List<WorkoutModel>>(
              stream: provider.searchStream(_termoBusca, _ordenacao),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFE10600)),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar dados: ${snapshot.error}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final resultados = snapshot.data ?? [];

                if (resultados.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            color: Colors.grey[700], size: 60),
                        SizedBox(height: 12),
                        Text(
                          _termoBusca.isEmpty
                              ? 'Digite algo para pesquisar.'
                              : 'Nenhum resultado para "$_termoBusca".',
                          style: TextStyle(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        '${resultados.length} resultado(s) encontrado(s)',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: resultados.length,
                        itemBuilder: (context, index) {
                          final w = resultados[index];
                          return _cardResultado(w);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardResultado(WorkoutModel w) {
    Color _corDificuldade(String d) {
      switch (d) {
        case 'Iniciante':
          return Colors.green;
        case 'Intermediário':
          return Colors.orange;
        case 'Avançado':
          return Colors.red;
        default:
          return Colors.blue;
      }
    }

    return Card(
      color: Color(0xFF1A1A1A),
      margin: EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Text(w.icon, style: TextStyle(fontSize: 28)),
        title: Text(
          w.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              w.description,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                _chip(w.category, Color(0xFFE10600).withOpacity(0.2),
                    Color(0xFFE10600)),
                _chip(w.difficulty,
                    _corDificuldade(w.difficulty).withOpacity(0.15),
                    _corDificuldade(w.difficulty)),
                _chip(w.duration, Colors.blue.withOpacity(0.15),
                    Colors.blue),
              ],
            ),
          ],
        ),
        trailing: w.isFavorite
            ? Icon(Icons.favorite, color: Colors.pink, size: 18)
            : null,
      ),
    );
  }

  Widget _chip(String label, Color bg, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
