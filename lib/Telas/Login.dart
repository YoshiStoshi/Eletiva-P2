// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/Autentificacao.dart';
import 'Registre-se.dart';
import 'Esqueceu_senha.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _txtEmail = TextEditingController();
  final _txtSenha = TextEditingController();
  bool _verSenha = false;

  @override
  void dispose() {
    _txtEmail.dispose();
    _txtSenha.dispose();
    super.dispose();
  }

  void _fazerLogin() async {
    final auth = context.read<AuthProvider>();
    // RF001 — Login via Firebase Authentication
    final erro = await auth.login(_txtEmail.text, _txtSenha.text);
    if (erro != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro),
          backgroundColor: Color(0xFFE10600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.fitness_center, color: Colors.white, size: 50),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Power House GYM',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Faça login para continuar',
                style: TextStyle(color: Colors.grey[400], fontSize: 15),
              ),
              SizedBox(height: 40),

              // Campo E-mail
              TextField(
                controller: _txtEmail,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.email_outlined, color: Color(0xFFE10600)),
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
              SizedBox(height: 16),

              // Campo Senha
              TextField(
                controller: _txtSenha,
                obscureText: !_verSenha,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.lock_outline, color: Color(0xFFE10600)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _verSenha ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[400],
                    ),
                    onPressed: () => setState(() => _verSenha = !_verSenha),
                  ),
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
              SizedBox(height: 8),

              // RF001 — Link para recuperação de senha
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EsqueceuSenha()),
                  ),
                  child: Text(
                    'Esqueceu a senha?',
                    style: TextStyle(color: Color(0xFFE10600)),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Botão Entrar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _fazerLogin,
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
                          'Entrar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              SizedBox(height: 24),

              // Link para cadastro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ainda não tem conta? ',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Registrese()),
                    ),
                    child: Text(
                      'Cadastre-se',
                      style: TextStyle(
                        color: Color(0xFFE10600),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
