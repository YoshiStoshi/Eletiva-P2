// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/Autentificacao.dart';

class Registrese extends StatefulWidget {
  const Registrese({super.key});

  @override
  State<Registrese> createState() => _RegistreseState();
}

class _RegistreseState extends State<Registrese> {
  final _txtNome = TextEditingController();
  final _txtEmail = TextEditingController();
  final _txtTelefone = TextEditingController();
  final _txtSenha = TextEditingController();
  final _txtConfirmarSenha = TextEditingController();
  bool _verSenha = false;
  bool _verConfirmar = false;

  @override
  void dispose() {
    _txtNome.dispose();
    _txtEmail.dispose();
    _txtTelefone.dispose();
    _txtSenha.dispose();
    _txtConfirmarSenha.dispose();
    super.dispose();
  }

  // RF002 — Validação de força de senha
  String _forcaSenha(String senha) {
    if (senha.isEmpty) return '';
    if (senha.length < 6) return 'Fraca';
    bool tem_maiuscula = senha.contains(RegExp(r'[A-Z]'));
    bool tem_minuscula = senha.contains(RegExp(r'[a-z]'));
    bool tem_numero = senha.contains(RegExp(r'\d'));
    bool tem_especial = senha.contains(RegExp(r'[!@#\$%^&*]'));
    int pontos = [tem_maiuscula, tem_minuscula, tem_numero, tem_especial]
        .where((v) => v)
        .length;
    if (pontos <= 2) return 'Fraca';
    if (pontos == 3) return 'Média';
    return 'Forte';
  }

  Color _corForca(String forca) {
    switch (forca) {
      case 'Fraca':
        return Colors.red;
      case 'Média':
        return Colors.orange;
      case 'Forte':
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }

  void _cadastrar() async {
    final auth = context.read<AuthProvider>();
    // RF002 — Registro via Firebase Auth + dados no Firestore
    final erro = await auth.register(
      name: _txtNome.text,
      email: _txtEmail.text,
      phone: _txtTelefone.text,
      password: _txtSenha.text,
      confirmPassword: _txtConfirmarSenha.text,
    );

    if (erro != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro),
          backgroundColor: Color(0xFFE10600),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conta criada com sucesso! Bem-vindo(a)!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    bool? verSenha,
    VoidCallback? toggleVer,
    TextInputType type = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure && !(verSenha ?? false),
      keyboardType: type,
      style: TextStyle(color: Colors.white),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Color(0xFFE10600)),
        suffixIcon: (obscure && toggleVer != null)
            ? IconButton(
                icon: Icon(
                  (verSenha ?? false) ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400],
                ),
                onPressed: toggleVer,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final forca = _forcaSenha(_txtSenha.text);

    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Criar Conta', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Junte-se a nós!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Preencha todos os campos para criar sua conta.',
                style: TextStyle(color: Colors.grey[400]),
              ),
              SizedBox(height: 28),

              // RF002 — Nome
              _campo(
                controller: _txtNome,
                label: 'Nome completo',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 16),

              // RF002 — E-mail
              _campo(
                controller: _txtEmail,
                label: 'E-mail',
                icon: Icons.email_outlined,
                type: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),

              // RF002 — Telefone (campo adicional)
              _campo(
                controller: _txtTelefone,
                label: 'Telefone',
                icon: Icons.phone_outlined,
                type: TextInputType.phone,
              ),
              SizedBox(height: 16),

              // RF002 — Senha com validação de força
              _campo(
                controller: _txtSenha,
                label: 'Senha',
                icon: Icons.lock_outline,
                obscure: true,
                verSenha: _verSenha,
                toggleVer: () => setState(() => _verSenha = !_verSenha),
                onChanged: (_) => setState(() {}),
              ),

              // Indicador de força de senha
              if (_txtSenha.text.isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Força da senha: ',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                    Text(
                      forca,
                      style: TextStyle(
                        color: _corForca(forca),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Use maiúsculas, minúsculas e números.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
              SizedBox(height: 16),

              // RF002 — Confirmar senha
              _campo(
                controller: _txtConfirmarSenha,
                label: 'Confirmar senha',
                icon: Icons.lock_outline,
                obscure: true,
                verSenha: _verConfirmar,
                toggleVer: () =>
                    setState(() => _verConfirmar = !_verConfirmar),
              ),
              SizedBox(height: 28),

              // Botão cadastrar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _cadastrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE10600),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: auth.isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Criar Conta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
