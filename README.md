<div align="center">

<img src="assets/logo.jpg" alt="Power House GYM Logo" width="120" style="border-radius: 16px"/>

# 💪 Power House Fitness GYM

### Aplicativo Mobile — Flutter + Firebase

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=flat-square&logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Integrado-FFCA28?style=flat-square&logo=firebase)
![Firestore](https://img.shields.io/badge/Firestore-Tempo%20Real-FF6F00?style=flat-square&logo=firebase)
![Versão](https://img.shields.io/badge/Versão-Beta-E10600?style=flat-square)

</div>

---

## 📖 Sobre o Projeto

O **Power House GYM** é um aplicativo mobile multiplataforma desenvolvido em **Flutter/Dart** com integração completa ao **Google Firebase**. O app oferece autenticação segura, dados em tempo real via Firestore, pesquisa avançada e consumo de API REST externa.

---

## ✨ Funcionalidades

| #   | Tela                   | Descrição                                                     |
| --- | ---------------------- | ------------------------------------------------------------- |
| 1   | 🔐 **Login**           | Autenticação via Firebase Authentication com feedback de erro |
| 2   | 📝 **Cadastro**        | Registro com Firebase Auth + dados salvos no Firestore        |
| 3   | 🔑 **Recuperar senha** | Redefinição de senha por e-mail via Firebase                  |
| 4   | 🏠 **Dashboard**       | Resumo em tempo real com StreamBuilder                        |
| 5   | 🏋️ **Treinos**         | Catálogo com GridView e filtro por categoria (Firestore)      |
| 6   | 📅 **Agenda**          | Grade semanal de aulas com inscrição/cancelamento (Firestore) |
| 7   | 💳 **Planos**          | Visualização e registro de matrícula no Firestore             |
| 8   | 🔍 **Pesquisa**        | Busca case-insensitive com ordenação (RF006)                  |
| 9   | 🌐 **API Exercícios**  | Biblioteca via API pública wger.de (RF007)                    |
| 10  | ℹ️ **Sobre**           | Equipe, tecnologias e informações acadêmicas                  |

---

## 🗂️ Estrutura do Projeto

```
lib/
├── main.dart                      # Entrada + Firebase.initializeApp + MultiProvider
├── firebase_options.dart          # Configurações do Firebase (gerado pelo FlutterFire CLI)
├── services/
│   ├── firebase_service.dart      # Helper de acesso ao Auth e Firestore
│   └── api_service.dart           # RF007 — Consumo da API wger.de
├── providers/
│   ├── Autentificacao.dart        # RF001, RF002 — Firebase Auth + ChangeNotifier
│   ├── Treino_provedor.dart       # RF003–RF006 — CRUD treinos no Firestore
│   ├── Planos_provedor.dart       # RF003, RF004, RF005 — Matrículas no Firestore
│   └── Agendar_provedor.dart      # RF003, RF004, RF005 — Agendamentos no Firestore
└── Telas/
    ├── Login.dart                 # RF001 — Login
    ├── Registre-se.dart           # RF002 — Cadastro
    ├── Esqueceu_senha.dart        # RF001 — Recuperação de senha
    ├── Home.dart                  # Navegação principal + seed inicial
    ├── Painel.dart                # Dashboard com StreamBuilders
    ├── Treinos.dart               # RF005 — StreamBuilder + GridView
    ├── Agendamento.dart           # RF005 — StreamBuilder + ListView
    ├── Planos.dart                # RF005 — StreamBuilder + ListView
    ├── Pesquisa.dart              # RF006 — Pesquisa exclusiva com ordenação
    ├── ApiExercicios.dart         # RF007 — API REST pública
    └── Sobre.dart                 # Informações do projeto
```

---

## ✅ Requisitos Atendidos

| RF    | Descrição                                                            | Status |
| ----- | -------------------------------------------------------------------- | ------ |
| RF001 | Login + recuperação via Firebase Authentication                      | ✅     |
| RF002 | Cadastro Firebase Auth + campos no Firestore                         | ✅     |
| RF003 | Inserção em 4 coleções (usuarios, treinos, agendamentos, matriculas) | ✅     |
| RF004 | Atualização em treinos, agendamentos e matriculas                    | ✅     |
| RF005 | StreamBuilder + ListView/GridView em tempo real — 2 coleções         | ✅     |
| RF006 | Tela exclusiva de pesquisa com ordenação e case-insensitive          | ✅     |
| RF007 | Consumo de API REST pública (wger.de)                                | ✅     |

| RNF  | Descrição                          | Status |
| ---- | ---------------------------------- | ------ |
| RNF1 | Flutter SDK + Dart                 | ✅     |
| RNF2 | Integração Google Firebase         | ✅     |
| RNF3 | Firebase Hosting                   | ✅     |
| RNF4 | Design intuitivo Material Design 3 | ✅     |

---

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK >= 3.0.0
- Conta no [Firebase Console](https://console.firebase.google.com)

### Passos

```bash
# 1. Instalar dependências
flutter pub get

# 2. Rodar no emulador ou dispositivo
flutter run

# 3. Gerar APK Android
flutter build apk --release

# 4. Build para Web (Firebase Hosting)
flutter build web
```

---

## 🗄️ Estrutura do Firestore

```
usuarios/
  └── {uid}/
        ├── nome, email, telefone, dataCadastro
        ├── treinos/
        │     └── {id} — name, category, duration, difficulty, description, icon, isFavorite, nameLower
        ├── agendamentos/
        │     └── {id} — workoutName, dayOfWeek, time, instructor, spotsTotal, spotsAvailable, isBooked
        └── matriculas/
              └── {id} — planName, period, price, status, createdAt
```

---

## 🌐 Firebase Hosting

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login e inicializar
firebase login
firebase init hosting

# Publicar
flutter build web
firebase deploy
```

---

## 📦 Dependências

```yaml
firebase_core: ^4.9.0 # Core Firebase
firebase_auth: ^6.5.1 # Autenticação
cloud_firestore: ^6.4.1 # Banco de dados em tempo real
provider: ^6.1.1 # Gerenciamento de estado
http: ^1.2.2 # Consumo de API REST
```

---

## 👥 Equipe

| Nome                      | Função                                                  |
| ------------------------- | ------------------------------------------------------- |
| Rodrigo de Azevedo Junior | Desenvolvedor, Integracao com FireBase, Editor do Video |
| Davi Sousa Cirilo         | Desenvolvedor, Apresentador do Projeto                  |

---

## 🏫 Informações Acadêmicas

- **Disciplina:** Dispositivos Moveis
- **Instituição:** FATEC Ribeirão Preto
- **Professor:** Prof. Rodrigo Plotze
- **Semestre:** 4º Semestre / 2026

---

<div align="center">
  <sub>© 2026 Power House Fitness GYM · Todos os direitos reservados.</sub>
</div>
