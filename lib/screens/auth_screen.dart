import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // Controlador para el nombre
  bool _isLogin = true;
  bool _isLoading = false;

  void _submitEmail() async {
    // Validación básica para el registro
    if (!_isLogin && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, ingresa tu nombre')));
      return;
    }

    setState(() => _isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String? error;

    if (_isLogin) {
      error = await userProvider.login(_emailController.text, _passwordController.text);
    } else {
      // Enviamos el nombre al método signUp
      error = await userProvider.signUp(_emailController.text, _passwordController.text, _nameController.text.trim());
    }

    setState(() => _isLoading = false);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _submitGoogle() async {
    setState(() => _isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final error = await userProvider.signInWithGoogle();

    setState(() => _isLoading = false);
    if (error != null && error != 'Inicio de sesión cancelado' && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  _isLogin ? '¡Bienvenido de nuevo!' : 'Crea tu cuenta',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // Campo condicional: Solo aparece al registrarse
                if (!_isLogin) ...[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Nombre completo',
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                ],

                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    fillColor: Colors.white.withOpacity(0.1),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    fillColor: Colors.white.withOpacity(0.1),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Column(
                  children: [
                    ElevatedButton(
                      onPressed: _submitEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse', style: const TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _isLogin = !_isLogin;
                        _nameController.clear(); // Limpiamos al cambiar de modo
                      }),
                      child: Text(
                        _isLogin ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Inicia sesión',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('O continúa con', style: TextStyle(color: Colors.white54)),
                        ),
                        Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: _submitGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 36, color: Colors.white),
                      label: const Text('Google', style: TextStyle(fontSize: 18, color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}