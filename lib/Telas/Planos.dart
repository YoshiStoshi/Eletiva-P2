// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/Planos_provedor.dart';

class Planos extends StatelessWidget {
  const Planos({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlanProvider>();

    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escolha seu Plano',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Selecione o período e o plano ideal para você.',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            SizedBox(height: 20),

            // Seletor de período
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: provider.periods.map((p) {
                  final sel = provider.selectedPeriod == p;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => provider.selectPeriod(p),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: sel ? Color(0xFFE10600) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          p,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: sel ? Colors.white : Colors.grey[400],
                            fontWeight: sel
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),

            // Cards dos planos
            ...provider.plans.map((plan) {
              final preco = provider.getPriceForPlan(plan);
              final selecionado = provider.selectedPlanId == plan.id;

              return GestureDetector(
                onTap: () => provider.selectPlan(plan.id),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selecionado
                          ? Color(0xFFE10600)
                          : plan.isHighlighted
                              ? Color(0xFFE10600).withOpacity(0.4)
                              : Colors.grey[800]!,
                      width: selecionado ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (plan.badge.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFFE10600),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                plan.badge,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'R\$ ${preco.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Color(0xFFE10600),
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '/mês',
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      ...plan.benefits.map(
                        (b) => Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  b,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // RF003 — Inserção matrícula
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final erro = await provider.subscribePlan(plan);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  erro ??
                                      'Matrícula no plano ${plan.name} realizada!',
                                ),
                                backgroundColor:
                                    erro != null ? Colors.red : Colors.green,
                              ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selecionado
                                ? Color(0xFFE10600)
                                : Color(0xFF2A2A2A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Assinar Agora',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // RF005 — StreamBuilder + ListView de matrículas ativas
            SizedBox(height: 8),
            Text(
              'Minhas Matrículas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            StreamBuilder<List<MatriculaModel>>(
              stream: provider.matriculasStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFE10600)),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    'Erro ao carregar dados: ${snapshot.error}',
                    style: TextStyle(color: Colors.grey),
                  );
                }

                final matriculas = snapshot.data ?? [];
                if (matriculas.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Nenhuma matrícula encontrada.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: matriculas.length,
                  itemBuilder: (context, index) {
                    final m = matriculas[index];
                    return Card(
                      color: Color(0xFF1A1A1A),
                      margin: EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.credit_card,
                            color: Color(0xFFE10600)),
                        title: Text(
                          '${m.planName} — ${m.period}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'R\$ ${m.price.toStringAsFixed(2)}/mês',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: m.status == 'ativo'
                                ? Colors.green.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            m.status.toUpperCase(),
                            style: TextStyle(
                              color: m.status == 'ativo'
                                  ? Colors.green
                                  : Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // RF004 — Cancelar matrícula
                        onLongPress: () async {
                          if (m.status == 'ativo') {
                            final erro =
                                await provider.updateMatricula(m.id, 'cancelado');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    erro ?? 'Matrícula cancelada.'),
                                backgroundColor:
                                    erro != null ? Colors.red : Colors.orange,
                              ));
                            }
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
