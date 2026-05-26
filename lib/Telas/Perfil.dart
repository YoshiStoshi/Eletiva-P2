// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/Autentificacao.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  bool _salvando = false;
  bool _iniciado = false;
  String? _mensagem;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_iniciado) {
      final auth = context.watch<AuthProvider>();
      _nomeController.text = auth.name ?? '';
      _emailController.text = auth.email ?? '';
      _telefoneController.text = auth.phone ?? '';
      _iniciado = true;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _salvando = true;
      _mensagem = null;
    });

    final auth = context.read<AuthProvider>();
    final resultado = await auth.updateProfile(
      name: _nomeController.text.trim(),
      phone: _telefoneController.text.trim(),
    );
    setState(() {
      _salvando = false;
      _mensagem = resultado ?? 'Dados atualizados com sucesso!';
    });

    if (resultado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dados atualizados com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        title: Text('Atualizar meus dados'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Atualize seu nome, e-mail e telefone.',
                style: TextStyle(color: Colors.grey[300], fontSize: 14),
              ),
              SizedBox(height: 16),
              _campoTexto(
                controller: _nomeController,
                label: 'Nome completo',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe seu nome.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              _campoTexto(
                controller: _emailController,
                label: 'E-mail',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
                validator: null,
              ),
              SizedBox(height: 12),
              _campoTexto(
                controller: _telefoneController,
                label: 'Telefone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe seu telefone.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE10600),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _salvando
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Salvar alterações'),
              ),
              if (_mensagem != null) ...[
                SizedBox(height: 16),
                Text(
                  _mensagem!,
                  style: TextStyle(
                    color: _mensagem!.contains('sucesso')
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Color(0xFFE10600)),
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
    );
  }
}
