// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/Treino_provedor.dart';

class Treinos extends StatefulWidget {
  const Treinos({super.key});

  @override
  State<Treinos> createState() => _TreinosState();
}

class _TreinosState extends State<Treinos> {
  String _categoriaFiltro = 'Todos';

  void _abrirFormulario({WorkoutModel? treino, String? docId}) {
    final provider = context.read<WorkoutProvider>();
    final _nome = TextEditingController(text: treino?.name ?? '');
    final _descricao = TextEditingController(text: treino?.description ?? '');
    final _duracao = TextEditingController(text: treino?.duration ?? '');
    String _categoria = treino?.category ?? 'Musculação';
    String _dificuldade = treino?.difficulty ?? 'Iniciante';
    String _icone = treino?.icon ?? '💪';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          title: Text(
            docId == null ? 'Adicionar Treino' : 'Editar Treino',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nome
                _campoTexto(_nome, 'Nome do treino', Icons.fitness_center),
                SizedBox(height: 12),

                // Categoria
                DropdownButtonFormField<String>(
                  value: _categoria,
                  dropdownColor: Color(0xFF2A2A2A),
                  style: TextStyle(color: Colors.white),
                  decoration: _decoracaoInput('Categoria', Icons.category),
                  items: ['Musculação', 'Coletiva', 'Personal']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => _categoria = v!),
                ),
                SizedBox(height: 12),

                // Duração
                _campoTexto(_duracao, 'Duração (ex: 60 min)', Icons.timer),
                SizedBox(height: 12),

                // Dificuldade
                DropdownButtonFormField<String>(
                  value: _dificuldade,
                  dropdownColor: Color(0xFF2A2A2A),
                  style: TextStyle(color: Colors.white),
                  decoration: _decoracaoInput('Dificuldade', Icons.bar_chart),
                  items: ['Iniciante', 'Intermediário', 'Avançado', 'Personalizado']
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => _dificuldade = v!),
                ),
                SizedBox(height: 12),

                // Descrição
                TextField(
                  controller: _descricao,
                  maxLines: 3,
                  style: TextStyle(color: Colors.white),
                  decoration: _decoracaoInput('Descrição', Icons.description),
                ),
                SizedBox(height: 12),

                // Ícone
                DropdownButtonFormField<String>(
                  value: _icone,
                  dropdownColor: Color(0xFF2A2A2A),
                  style: TextStyle(color: Colors.white),
                  decoration: _decoracaoInput('Ícone', Icons.emoji_emotions),
                  items: ['💪', '🥋', '🦵', '🏆', '🧘', '🏃', '🚴', '🤸']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => _icone = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Fechar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final w = WorkoutModel(
                  id: docId ?? '',
                  name: _nome.text,
                  category: _categoria,
                  duration: _duracao.text,
                  difficulty: _dificuldade,
                  description: _descricao.text,
                  icon: _icone,
                  isFavorite: treino?.isFavorite ?? false,
                );

                String? erro;
                if (docId == null) {
                  // RF003 — Inserção
                  erro = await provider.addWorkout(w);
                } else {
                  // RF004 — Atualização
                  erro = await provider.updateWorkout(docId, w.toMap());
                }

                Navigator.pop(ctx);
                if (erro != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(erro), backgroundColor: Colors.red),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(docId == null
                          ? 'Treino adicionado com sucesso!'
                          : 'Treino atualizado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE10600),
              ),
              child: Text('Salvar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoracaoInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Color(0xFFE10600)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFFE10600)),
      ),
      filled: true,
      fillColor: Color(0xFF2A2A2A),
    );
  }

  Widget _campoTexto(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: Colors.white),
      decoration: _decoracaoInput(label, icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutProvider>();

    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: Column(
        children: [
          // Filtro de categorias
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: provider.categories.map((cat) {
                final selecionado = _categoriaFiltro == cat;
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: selecionado,
                    onSelected: (_) =>
                        setState(() => _categoriaFiltro = cat),
                    backgroundColor: Color(0xFF1A1A1A),
                    selectedColor: Color(0xFFE10600).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: selecionado ? Color(0xFFE10600) : Colors.grey[400],
                    ),
                    side: BorderSide(
                      color: selecionado ? Color(0xFFE10600) : Colors.grey[700]!,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // RF005 — StreamBuilder + GridView em tempo real
          Expanded(
            child: StreamBuilder<List<WorkoutModel>>(
              stream: provider.workoutsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFFE10600)),
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

                final lista = snapshot.data ?? [];
                final filtrados = _categoriaFiltro == 'Todos'
                    ? lista
                    : lista
                        .where((w) => w.category == _categoriaFiltro)
                        .toList();

                if (filtrados.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center,
                            color: Colors.grey[700], size: 60),
                        SizedBox(height: 12),
                        Text(
                          'Nenhum treino encontrado.',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtrados.length,
                  itemBuilder: (context, index) {
                    final w = filtrados[index];
                    return _cardTreino(w, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
      // RF003 — Botão para adicionar novo treino
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Color(0xFFE10600),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _cardTreino(WorkoutModel w, WorkoutProvider provider) {
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

    return GestureDetector(
      // RF004 — Toque para editar
      onTap: () => _abrirFormulario(treino: w, docId: w.id),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(w.icon, style: TextStyle(fontSize: 28)),
                // RF004 — Favoritar
                GestureDetector(
                  onTap: () => provider.toggleFavorite(w.id, w.isFavorite),
                  child: Icon(
                    w.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: w.isFavorite ? Colors.pink : Colors.grey[600],
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              w.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer_outlined, color: Colors.grey[500], size: 12),
                SizedBox(width: 4),
                Text(
                  w.duration,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: _corDificuldade(w.difficulty).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    w.difficulty,
                    style: TextStyle(
                      color: _corDificuldade(w.difficulty),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // RF004 — Excluir com long press
                GestureDetector(
                  onLongPress: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Color(0xFF1A1A1A),
                        title: Text('Excluir',
                            style: TextStyle(color: Colors.white)),
                        content: Text(
                          'Deseja excluir "${w.name}"?',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Excluir',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirmar == true) {
                      final erro = await provider.deleteWorkout(w.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(erro ?? 'Treino excluído com sucesso!'),
                          backgroundColor: erro != null ? Colors.red : Colors.green,
                        ));
                      }
                    }
                  },
                  child: Icon(Icons.delete_outline,
                      color: Colors.grey[700], size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
