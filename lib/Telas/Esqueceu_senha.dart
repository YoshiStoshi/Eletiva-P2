// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/Autentificacao.dart';

class EsqueceuSenha extends StatefulWidget {
  const EsqueceuSenha({super.key});

  @override
  State<EsqueceuSenha> createState() => _EsqueceuSenhaState();
}

class _EsqueceuSenhaState extends State<EsqueceuSenha> {
  final _txtEmail = TextEditingController();
  bool _enviado = false;
  bool _carregando = false;

  @override
  void dispose() {
    _txtEmail.dispose();
    super.dispose();
  }

  void _recuperarSenha() async {
    final auth = context.read<AuthProvider>();
    setState(() => _carregando = true);

    // RF001 — Recuperação de senha via Firebase
    final erro = await auth.forgotPassword(_txtEmail.text);
    setState(() => _carregando = false);

    if (erro != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro),
          backgroundColor: Color(0xFFE10600),
        ),
      );
    } else if (mounted) {
      setState(() => _enviado = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Recuperar Senha', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: _enviado ? _telaSucesso() : _telaFormulario(),
        ),
      ),
    );
  }

  Widget _telaFormulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_reset, color: Color(0xFFE10600), size: 60),
        SizedBox(height: 20),
        Text(
          'Esqueceu sua senha?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Informe seu e-mail e enviaremos um link para redefinir sua senha.',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        SizedBox(height: 32),
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
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _carregando ? null : _recuperarSenha,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE10600),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _carregando
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Enviar Link',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _telaSucesso() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_email_read_outlined,
              color: Colors.green, size: 80),
          SizedBox(height: 24),
          Text(
            'E-mail enviado!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Color(0xFFE10600)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Voltar ao Login'),
            ),
          ),
        ],
      ),
    );
  }
}
