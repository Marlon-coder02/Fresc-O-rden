import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'inicio_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isPasswordVisible = false;
  String _passwordStrength = '';

  // Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // Asegura elegir cuenta nueva
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InicioScreen()),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error con Google: $e')),
      );
    }
  }

  // Registro / Login con correo y contraseña
  Future<void> submitEmailPassword() async {
    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InicioScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error desconocido')),
      );
    }
  }

  void evaluatePassword(String password) {
    String strength = '';
    if (password.length < 6) {
      strength = 'Débil';
    } else if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#\$&*~]'))) {
      strength = 'Fuerte';
    } else {
      strength = 'Media';
    }

    setState(() {
      _passwordStrength = strength;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Iniciar Sesión' : 'Crear Cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 16),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              onChanged: evaluatePassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                  },
                ),
              ),
            ),

            if (_passwordController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Fortaleza: $_passwordStrength',
                  style: TextStyle(
                    color: _passwordStrength == 'Fuerte'
                        ? Colors.green
                        : _passwordStrength == 'Media'
                            ? Colors.orange
                            : _passwordStrength == 'Débil'
                                ? Colors.red
                                : Colors.black
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Botón de login/registro
            ElevatedButton.icon(
              icon: Icon(_isLogin ? Icons.login : Icons.person_add),
              label: Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse'),
              onPressed: submitEmailPassword,
            ),

            const SizedBox(height: 16),

            // Alternar entre login y registro
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                  _passwordStrength = '';
                  _passwordController.clear();
                });
              },
              child: Text(_isLogin
                  ? '¿No tienes cuenta? Crear una'
                  : '¿Ya tienes cuenta? Iniciar sesión'),
            ),

            const Divider(height: 32),

            // Google Sign-in
            ElevatedButton.icon(
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Ingresar con Google'),
              onPressed: signInWithGoogle,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
