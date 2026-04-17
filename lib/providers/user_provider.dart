import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_stats.dart';
import '../models/achievement.dart';

enum MoodType { happy, focused, tired, stressed }
enum EnergyLevel { low, medium, high }

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isGoogleSignInInitialized = false;

  User? _user;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  String _userName = "Usuario";
  String get userName => _userName;

  MoodType _currentMood = MoodType.happy;
  MoodType get currentMood => _currentMood;

  EnergyLevel _energyLevel = EnergyLevel.high;
  EnergyLevel get energyLevel => _energyLevel;

  UserStats _stats = UserStats(
    level: 0,
    xp: 0,
    xpToNextLevel: 100,
    currentStreak: 0,
    productivityScore: 0,
    tasksCompleted: 0,
  );
  UserStats get stats => _stats;

  List<Achievement> _unlockedAchievements = [];
  List<Achievement> get unlockedAchievements => _unlockedAchievements;

  List<Achievement> _inProgressAchievements = [];
  List<Achievement> get inProgressAchievements => _inProgressAchievements;

  UserProvider() {
    _initGoogleSignIn();
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          _userName = user.displayName!;
        }
        _listenToStats(user.uid);
      } else {
        _userName = "Usuario";
        _stats = UserStats(level: 0, xp: 0, xpToNextLevel: 100, currentStreak: 0, productivityScore: 0, tasksCompleted: 0);
        notifyListeners();
      }
    });
  }

  void _listenToStats(String uid) {
    _db.collection('users').doc(uid).collection('metadata').doc('stats')
        .snapshots()
        .listen((doc) async {
      if (doc.exists) {
        _stats = UserStats.fromJson(doc.data()!);
      } else {
        await _initializeStats(uid);
      }
      notifyListeners();
    });
  }

  Future<void> _initializeStats(String uid) async {
    final initialStats = UserStats(
      level: 0,
      xp: 0,
      xpToNextLevel: 100,
      currentStreak: 0,
      productivityScore: 0,
      tasksCompleted: 0,
      lastActiveDate: null,
    );
    await _db.collection('users').doc(uid).collection('metadata').doc('stats').set(initialStats.toJson());
  }

  // --- EL CORAZÓN DE TU SISTEMA: EXPERIENCIA Y RACHA ---
  Future<void> addExperience(int amount) async {
    if (_user == null) return;

    int newXp = _stats.xp + amount;
    int newLevel = _stats.level;
    int newXpToNext = _stats.xpToNextLevel;

    // Sube de nivel si es necesario
    while (newXp >= newXpToNext) {
      newXp -= newXpToNext;
      newLevel++;

      if (newLevel == 1) newXpToNext = 250;
      else if (newLevel == 2) newXpToNext = 500;
      else if (newLevel == 3) newXpToNext = 1000;
      else newXpToNext = (newXpToNext * 1.3).toInt();
    }

    // ACTUALIZACIÓN DE RACHA DIARIA
    // Obtenemos la fecha de hoy en formato "YYYY-MM-DD"
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    int newStreak = _stats.currentStreak;
    String? newLastActive = _stats.lastActiveDate;

    // Si la última actividad no fue hoy...
    if (_stats.lastActiveDate != todayStr) {
      if (_stats.lastActiveDate != null) {
        final lastDate = DateTime.parse(_stats.lastActiveDate!);
        final todayDate = DateTime.parse(todayStr);
        final diff = todayDate.difference(lastDate).inDays;

        if (diff == 1) {
          newStreak++; // Fue ayer, la racha aumenta
        } else if (diff > 1) {
          newStreak = 1; // Faltaste un día, la racha se reinicia
        }
      } else {
        newStreak = 1; // Es la primera vez que completas algo
      }
      newLastActive = todayStr; // Marcamos hoy como el último día activo
    }

    await _db.collection('users').doc(_user!.uid).collection('metadata').doc('stats').update({
      'xp': newXp,
      'level': newLevel,
      'xpToNextLevel': newXpToNext,
      'tasksCompleted': FieldValue.increment(1),
      'currentStreak': newStreak,
      'lastActiveDate': newLastActive,
    });
  }

  void setMood(MoodType mood) {
    _currentMood = mood;
    notifyListeners();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 20) return 'Buenas tardes';
    return 'Buenas noches';
  }

  Future<void> _initGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      debugPrint("Error inicializando Google Sign In: $e");
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (!_isGoogleSignInInitialized) await _initGoogleSignIn();
  }

  Future<String?> signUp(String email, String password, String name) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);
      _userName = name;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signInWithGoogle() async {
    await _ensureGoogleInitialized();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      if (googleUser == null) return 'Inicio de sesión cancelado';

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final authorizedUser = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorizedUser.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}