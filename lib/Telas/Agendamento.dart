// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/Agendar_provedor.dart';

class Agendamento extends StatefulWidget {
  const Agendamento({super.key});

  @override
  State<Agendamento> createState() => _AgendamentoState();
}

class _AgendamentoState extends State<Agendamento> {
  String _diaSelecionado = 'Segunda';

  void _abrirFormulario() {
    final provider = context.read<ScheduleProvider>();
    final _aula = TextEditingController();
    final _horario = TextEditingController();
    final _instrutor = TextEditingController();
    final _vagas = TextEditingController(text: '20');
    String _dia = _diaSelecionado;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          title: Text('Adicionar Aula', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campo(_aula, 'Nome da aula', Icons.sports),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _dia,
                  dropdownColor: Color(0xFF2A2A2A),
                  style: TextStyle(color: Colors.white),
                  decoration: _decoracao('Dia da semana', Icons.calendar_today),
                  items: provider.days
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => _dia = v!),
                ),
                SizedBox(height: 12),
                _campo(_horario, 'Horário (ex: 19:00)', Icons.access_time),
                SizedBox(height: 12),
                _campo(_instrutor, 'Instrutor', Icons.person),
                SizedBox(height: 12),
                _campo(_vagas, 'Total de vagas', Icons.group,
                    type: TextInputType.number),
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
                final vagas = int.tryParse(_vagas.text) ?? 20;
                final entry = ScheduleEntry(
                  id: '',
                  workoutName: _aula.text,
                  dayOfWeek: _dia,
                  time: _horario.text,
                  instructor: _instrutor.text,
                  spotsTotal: vagas,
                  spotsAvailable: vagas,
                );
                // RF003 — Inserção na coleção agendamentos
                final erro = await provider.addEntry(entry);
                Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text(erro ?? 'Aula adicionada com sucesso!'),
                    backgroundColor: erro != null ? Colors.red : Colors.green,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE10600)),
              child: Text('Salvar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoracao(String label, IconData icon) {
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

  Widget _campo(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: TextStyle(color: Colors.white),
      decoration: _decoracao(label, icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ScheduleProvider>();

    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: Column(
        children: [
          // Seleção de dia
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: provider.days.map((dia) {
                final sel = _diaSelecionado == dia;
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(dia),
                    selected: sel,
                    onSelected: (_) =>
                        setState(() => _diaSelecionado = dia),
                    backgroundColor: Color(0xFF1A1A1A),
                    selectedColor: Color(0xFFE10600).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: sel ? Color(0xFFE10600) : Colors.grey[400],
                      fontWeight:
                          sel ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: sel ? Color(0xFFE10600) : Colors.grey[700]!,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // RF005 — StreamBuilder + ListView em tempo real
          Expanded(
            child: StreamBuilder<List<ScheduleEntry>>(
              stream: provider.getEntriesStream(_diaSelecionado),
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

                final dados = snapshot.data ?? [];

                if (dados.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy,
                            color: Colors.grey[700], size: 60),
                        SizedBox(height: 12),
                        Text(
                          'Nenhuma aula em $_diaSelecionado.',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: dados.length,
                  itemBuilder: (context, index) {
                    final item = dados[index];
                    return _cardAula(item, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
      // RF003 — Adicionar nova aula
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormulario,
        backgroundColor: Color(0xFFE10600),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _cardAula(ScheduleEntry entry, ScheduleProvider provider) {
    final ocupacao = entry.spotsTotal > 0
        ? (entry.spotsTotal - entry.spotsAvailable) / entry.spotsTotal
        : 0.0;

    return Card(
      color: Color(0xFF1A1A1A),
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(0xFFE10600).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              entry.time,
              style: TextStyle(
                color: Color(0xFFE10600),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        title: Text(
          entry.workoutName,
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
              '👤 ${entry.instructor}',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: ocupacao,
                    backgroundColor: Colors.grey[800],
                    color: ocupacao > 0.8 ? Colors.red : Color(0xFFE10600),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${entry.spotsAvailable}/${entry.spotsTotal} vagas',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        // RF004 — Inscrever / cancelar
        trailing: entry.isBooked
            ? ElevatedButton(
                onPressed: () async {
                  final erro = await provider.cancelBooking(entry.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(erro ?? 'Inscrição cancelada.'),
                      backgroundColor: erro != null ? Colors.red : Colors.orange,
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                ),
                child: Text('Cancelar',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              )
            : ElevatedButton(
                onPressed: entry.spotsAvailable <= 0
                    ? null
                    : () async {
                        final erro = await provider.bookClass(entry.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text(erro ?? 'Inscrição realizada com sucesso!'),
                            backgroundColor:
                                erro != null ? Colors.red : Colors.green,
                          ));
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE10600),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                ),
                child: Text('Inscrever',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
      ),
    );
  }
}
