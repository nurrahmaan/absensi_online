import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth/login_provider.dart';
import '../dashboard/home_screen.dart';
import '../../widgets/notifications/top_notification.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkSavedLogin();
  }

  Future<void> _checkSavedLogin() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final token = await loginProvider.getSavedToken();
    if (token != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(token: token)),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B2FF7), Color(0xFF2AFADF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Card(
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              shadowColor: Colors.black.withOpacity(0.25),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.fingerprint,
                        size: 80, color: Colors.deepPurple.shade700),
                    const SizedBox(height: 16),
                    Text(
                      "Absensi Online",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: "Username",
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: loginProvider.isLoading
                          ? null
                          : () async {
                              final success = await loginProvider.login(
                                _usernameController.text,
                                _passwordController.text,
                              );
                              if (mounted) {
                                if (success) {
                                  final token =
                                      await loginProvider.getSavedToken() ?? '';
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HomeScreen(token: token),
                                    ),
                                  );
                                  showTopNotification(
                                    context,
                                    "Login berhasil",
                                    isError: false,
                                  );
                                } else {
                                  showTopNotification(
                                    context,
                                    loginProvider.errorMessage ?? "Login gagal",
                                    isError: true,
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: loginProvider.isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              "Login",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Lupa password?",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.deepPurple.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
