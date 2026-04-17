import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Importamos tus modelos reales para las estadísticas
import '../models/user_stats.dart';
import '../models/achievement.dart';

// Recuperamos los Enums que necesita tu DashboardScreen
enum MoodType { happy, focused, tired, stressed }
enum EnergyLevel { low, medium, high }

class UserProvider with ChangeNotifier {

  // ==========================================
  // 1. LÓGICA DE FIREBASE Y GOOGLE (v7.2.0)
  // ==========================================
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // En v7+, GoogleSignIn es un Singleton obligatorio
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  User? _user;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  // ==========================================
  // 2. LÓGICA DE INTERFAZ DEL DASHBOARD
  // ==========================================
  String _userName = "Usuario";
  String get userName => _userName;

  MoodType _currentMood = MoodType.happy;
  MoodType get currentMood => _currentMood;

  EnergyLevel _energyLevel = EnergyLevel.high;
  EnergyLevel get energyLevel => _energyLevel;

  // Conectamos con tu clase UserStats
  UserStats _stats = UserStats(
    level: 12,
    xp: 2840,
    xpToNextLevel: 3500,
    currentStreak: 7,
    productivityScore: 87,
    tasksCompleted: 45,
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
      // Actualiza la interfaz con el nombre real de Firebase/Google si existe
      if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
        _userName = user.displayName!;
      } else {
        _userName = "Usuario";
      }
      notifyListeners();
    });
  }

  // --- MÉTODOS DEL DASHBOARD ---
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

  // ==========================================
  // 3. MÉTODOS DE AUTENTICACIÓN
  // ==========================================

  // En v7+ es obligatorio inicializar Google de forma asíncrona
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

  // REGISTRO: Ahora recibe y guarda el nombre
  Future<String?> signUp(String email, String password, String name) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Actualiza el perfil de Firebase con el nombre
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
      // En v7+ usamos authenticate() obligatoriamente
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      if (googleUser == null) return 'Inicio de sesión cancelado';

      // En v7+ authentication es síncrona, y la autorización de scopes es separada
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