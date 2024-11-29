import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:online_shop/fitur/login_page.dart';
import '../hive/user.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;

  // Metode hash password yang konsisten
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Validasi password
  bool _validatePassword(String password) {
    // Minimal 8 karakter, mengandung huruf besar, huruf kecil, angka, dan karakter spesial
    final passwordRegex = 
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    return RegExp(passwordRegex).hasMatch(password);
  }

  void _register(BuildContext context) async {
    final username = _usernameController.text.trim(); 
    final password = _passwordController.text.trim(); 

    // Validasi input
    if (username.isEmpty) {
      _showErrorDialog('Username tidak boleh kosong');
      return;
    }

    if (!_validatePassword(password)) {
      _showErrorDialog('Password harus minimal 8 karakter dan mengandung huruf besar, huruf kecil, angka, dan karakter spesial');
      return;
    }
    
    final box = Hive.box<User>('users');
    
    // Mengecek apakah username sudah terdaftar
    final userExists = box.values.any((user) => user.username == username);

    if (userExists) {
      _showErrorDialog('Username sudah terdaftar.');
    } else {
      // Hash password sebelum disimpan
      String hashedPassword = _hashPassword(password);
      
      final user = User(username: username, password: hashedPassword);
      await box.add(user);

      // Tampilkan dialog sukses dan kembali ke login
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Berhasil'),
          content: const Text('Akun berhasil dibuat!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Metode untuk menampilkan dialog error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kesalahan'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; 
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1), 
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              const SizedBox(height: 80), 
              const Text(
                "Sign Up",
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold), 
              ),
              const SizedBox(height: 30), 
              _buildLogo(size), 
              const SizedBox(height: 50), 
              _buildUsernameField(), 
              const SizedBox(height: 20), 
              _buildPasswordField(), 
              const SizedBox(height: 30), 
              _buildRegisterButton(), 
              const SizedBox(height: 15), 
              _buildLoginLink(), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Size size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15), 
      child: Image.asset(
        'assets/images/shop.jpeg', 
        width: size.width * 0.5, 
        height: size.width * 0.5, 
        fit: BoxFit.cover, 
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: 'Username',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(Icons.person),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _isObscured,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: () => _register(context), 
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 15),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const SizedBox(
        width: double.infinity, 
        child: Text(
          "Sign Up", 
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18), 
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
      child: const Text(
        "Sudah punya akun? Login di sini", 
        style: TextStyle(color: Colors.blue),
      ),
    );
  }
}