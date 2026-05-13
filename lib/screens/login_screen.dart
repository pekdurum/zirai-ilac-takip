import 'package:flutter/material.dart';
import 'package:zirai_ilac_takip/core/auth_service.dart';
import 'register_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _girisYap() async {
    // 1. Klavyeyi kapat (Chrome çökmesini engeller)
    FocusScope.of(context).unfocus(); 
    
    setState(() => _isLoading = true);
    try {
      await _authService.girisYap(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // DİKKAT PATRON: Burada artık Navigator ile sayfa değiştirme KODU YOK!
      // Çünkü AuthGate işlemi algılayıp bizi anında Ana Ekrana çekecek.
    } catch (e) {
      if (mounted) {
        // Eğer şifre yanlışsa sana burası kırmızı uyarı verecek
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş Hatası: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Chrome klavye çökmesini tutar
      appBar: AppBar(
        title: const Text('Zirai İlaç Takip'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.agriculture, size: 80, color: Colors.green),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-Posta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _girisYap,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('GİRİŞ YAP', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text(
                'Hesabın yok mu? Yeni İşçi Kaydı', 
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
              ),
            )
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}