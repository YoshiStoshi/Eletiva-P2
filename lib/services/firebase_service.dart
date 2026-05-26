import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get db => FirebaseFirestore.instance;

  static Stream<User?> get authStateChanges => auth.authStateChanges();

  static String? get uid => auth.currentUser?.uid;

  // RF003/RF004/RF005 — Retorna referência da sub-coleção do usuário logado
  static CollectionReference userCollection(String collection) {
    return db
        .collection('usuarios')
        .doc(uid)
        .collection(collection);
  }
}
