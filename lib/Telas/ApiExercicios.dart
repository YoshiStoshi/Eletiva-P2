// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApiExercicios extends StatefulWidget {
  const ApiExercicios({super.key});

  @override
  State<ApiExercicios> createState() => _ApiExerciciosState();
}

class _ApiExerciciosState extends State<ApiExercicios> {
  final _txtBusca = TextEditingController();
  List<ExerciseModel> _exercicios = [];
  bool _carregando = false;
  bool _carregado = false;
  String _termoBusca = '';
  String? _erro;
  int _offset = 0;
  static const int _limite = 20;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _txtBusca.dispose();
    super.dispose();
  }

  Future<void> _carregar({bool resetar = false}) async {
    if (resetar) {
      setState(() {
        _offset = 0;
        _exercicios = [];
        _carregado = false;
        _erro = null;
      });
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final lista = await ApiService.fetchExercises(
        query: _termoBusca,
        offset: _offset,
        limit: _limite,
      );

      setState(() {
        _exercicios.addAll(lista);
        _offset += lista.length;
        _carregado = true;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

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
        title: Text(
          'Biblioteca de Exercícios',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(
                'API wger.de',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
              backgroundColor: Color(0xFFE10600).withOpacity(0.3),
              side: BorderSide(color: Color(0xFFE10600)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _txtBusca,
                    style: TextStyle(color: Colors.white),
                    onSubmitted: (_) {
                      _termoBusca = _txtBusca.text.trim();
                      _carregar(resetar: true);
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar exercício...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Color(0xFFE10600)),
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
                      suffixIcon: _txtBusca.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _txtBusca.clear();
                                _termoBusca = '';
                                _carregar(resetar: true);
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _termoBusca = _txtBusca.text.trim();
                    _carregar(resetar: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE10600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
          ),

          // Contador de resultados
          if (_carregado && _exercicios.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_exercicios.length} exercício(s) carregado(s)',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ),
            ),

          // Lista de exercícios
          Expanded(
            child: _carregando && _exercicios.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFE10600)),
                        SizedBox(height: 12),
                        Text(
                          'Carregando da API...',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : _erro != null
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  color: Color(0xFFE10600), size: 60),
                              SizedBox(height: 12),
                              Text(
                                'Não foi possível carregar os exercícios.',
                                style: TextStyle(color: Colors.grey[300]),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                _erro!,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _carregar(resetar: true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFE10600),
                                ),
                                child: Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _carregado && _exercicios.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sports_gymnastics,
                                    color: Colors.grey[700], size: 60),
                                SizedBox(height: 12),
                                Text(
                                  'Nenhum exercício encontrado.',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _exercicios.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _exercicios.length) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: _carregando
                                        ? CircularProgressIndicator(
                                            color: Color(0xFFE10600))
                                        : OutlinedButton.icon(
                                            onPressed: _carregar,
                                            icon: Icon(Icons.expand_more,
                                                color: Color(0xFFE10600)),
                                            label: Text(
                                              'Carregar mais',
                                              style: TextStyle(
                                                  color: Color(0xFFE10600)),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                  color: Color(0xFFE10600)),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                  ),
                                );
                              }

                              final ex = _exercicios[index];
                              return _cardExercicio(ex);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _cardExercicio(ExerciseModel ex) {
    return Card(
      color: Color(0xFF1A1A1A),
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[800]!),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Color(0xFFE10600).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '${ex.id}',
              style: TextStyle(
                color: Color(0xFFE10600),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          ex.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: ex.category.isNotEmpty
            ? Text(
                ex.category,
                style: TextStyle(color: Color(0xFFE10600), fontSize: 12),
              )
            : null,
        iconColor: Colors.grey[400],
        collapsedIconColor: Colors.grey[600],
        children: [
          if (ex.description.isNotEmpty) ...[
            Text(
              ex.description,
              style: TextStyle(color: Colors.grey[300], fontSize: 13),
            ),
            SizedBox(height: 10),
          ],
          if (ex.muscles.isNotEmpty)
            _infoRow(Icons.accessibility_new, 'Músculos', ex.muscles),
          if (ex.equipment.isNotEmpty)
            _infoRow(Icons.fitness_center, 'Equipamento', ex.equipment),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String valor) {
    return Padding(
      padding: EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFFE10600), size: 16),
          SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: valor,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
