import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get name => _userData?['nome'] ?? _currentUser?.displayName ?? '';
  String? get email => _currentUser?.email;

  AuthProvider() {
    FirebaseService.authStateChanges.listen((user) {
      _currentUser = user;
      if (user != null) _loadUserData(user.uid);
      notifyListeners();
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await FirebaseService.db.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        _userData = doc.data();
        notifyListeners();
      }
    } catch (_) {}
  }

  // RF001 — Login via Firebase Authentication
  Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) return 'Preencha todos os campos.';
    _isLoading = true;
    notifyListeners();
    try {
      await FirebaseService.auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      switch (e.code) {
        case 'user-not-found': return 'Usuário não encontrado.';
        case 'wrong-password': return 'Senha incorreta.';
        case 'invalid-email': return 'E-mail inválido.';
        case 'user-disabled': return 'Conta desativada.';
        case 'invalid-credential': return 'Credenciais inválidas.';
        default: return 'Erro ao fazer login: ${e.message}';
      }
    }
  }

  // RF002 — Cadastro via Firebase Auth + salva no Firestore
  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.isEmpty || email.isEmpty || phone.isEmpty ||
        password.isEmpty || confirmPassword.isEmpty) {
      return 'Preencha todos os campos obrigatórios.';
    }
    if (!_isValidEmail(email)) return 'E-mail inválido.';
    if (password != confirmPassword) return 'As senhas não coincidem.';
    if (password.length < 6) return 'Mínimo de 6 caracteres.';
    if (!_isStrongPassword(password)) {
      return 'A senha deve conter letras maiúsculas, minúsculas e números.';
    }

    _isLoading = true;
    notifyListeners();
    try {
      final credential = await FirebaseService.auth
          .createUserWithEmailAndPassword(email: email.trim(), password: password);

      // RF002 — Salva campos adicionais na coleção "usuarios" do Firestore
      await FirebaseService.db
          .collection('usuarios')
          .doc(credential.user!.uid)
          .set({
        'nome': name,
        'email': email.trim(),
        'telefone': phone,
        'dataCadastro': FieldValue.serverTimestamp(),
        'uid': credential.user!.uid,
      });

      await credential.user!.updateDisplayName(name);
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      switch (e.code) {
        case 'email-already-in-use': return 'E-mail já cadastrado.';
        case 'weak-password': return 'Senha fraca.';
        case 'invalid-email': return 'E-mail inválido.';
        default: return 'Erro ao criar conta: ${e.message}';
      }
    }
  }

  // RF001 — Recuperação de senha via Firebase
  Future<String?> forgotPassword(String email) async {
    if (email.isEmpty) return 'Informe o e-mail.';
    if (!_isValidEmail(email)) return 'E-mail inválido.';
    try {
      await FirebaseService.auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return 'Erro: ${e.message}';
    }
  }

  Future<void> logout() async {
    await FirebaseService.auth.signOut();
    _userData = null;
    notifyListeners();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  bool _isStrongPassword(String password) =>
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$').hasMatch(password);
}
