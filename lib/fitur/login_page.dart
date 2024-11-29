import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:online_shop/pembeli/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import '../hive/user.dart';
import '../admin/home_admin.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;

  // Metode enkripsi yang lebih sederhana dan konsisten
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi input
    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Username dan password tidak boleh kosong');
      return;
    }

    // Cek admin
    if (username == 'admin' && _hashPassword(password) == _hashPassword('admin')) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAdmin', true);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeAdmin()),
      );
      return;
    }

    // Cek user biasa dari Hive database
    final box = Hive.box<User>('users');
    
    try {
      // Gunakan firstWhere dengan orElse untuk menghindari exception
      final user = box.values.firstWhere(
        (user) => 
          user.username == username && 
          user.password == _hashPassword(password),
        orElse: () => User(username: '', password: ''),
      );

      if (user.username.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', username);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        _showErrorDialog('Username atau password salah');
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan saat login');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLogo(),
              SizedBox(height: 30),
              _buildUsernameField(),
              SizedBox(height: 15),
              _buildPasswordField(),
              SizedBox(height: 25),
              _buildLoginButton(),
              SizedBox(height: 15),
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          'assets/images/shop.jpeg', 
          width: 200, 
          height: 200, 
          fit: BoxFit.cover,
        ),
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

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 15),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'Login',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterPage()),
        );
      },
      child: Text(
        'Belum punya akun? Daftar di sini',
        style: TextStyle(color: Colors.blue),
      ),
    );
  }
}