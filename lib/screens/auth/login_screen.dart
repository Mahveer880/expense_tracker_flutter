import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/buttons/primary_button.dart';
import '../../widgets/textfields/custom_text_field.dart';

import '../../services/auth_service.dart';
import '../../services/google_auth_service.dart';

import '../../providers/transaction_provider.dart';

import 'signup_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // =====================================================
  // EMAIL / PASSWORD LOGIN
  // =====================================================

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final user = await AuthService.login(
      emailController.text.trim(),
      passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (user != null) {
      context.read<TransactionProvider>().loadTransactions();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Successful")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Email or Password")),
      );
    }
  }

  // =====================================================
  // GOOGLE LOGIN
  // =====================================================

  Future<void> loginWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = await GoogleAuthService.signIn();

      if (!mounted) return;

      if (user != null) {
        context.read<TransactionProvider>().loadTransactions();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Welcome ${user.name}")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Sign-In cancelled or failed")),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Google Sign-In failed: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =====================================================
  // GUEST LOGIN
  // =====================================================

  Future<void> loginAsGuest() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Guest ke liye existing saved session remove karte hain.
      await AuthService.logout();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Continuing as Guest")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to continue as Guest")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  const Icon(Icons.account_balance_wallet_rounded, size: 90),

                  const SizedBox(height: 20),

                  const Text(
                    "Expense Tracker",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  const Text("Manage Your Money Wisely"),

                  const SizedBox(height: 40),

                  // =========================
                  // EMAIL
                  // =========================
                  CustomTextField(
                    controller: emailController,
                    hintText: "Email",
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      }

                      if (!value.contains("@") || !value.contains(".")) {
                        return "Enter a valid email";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // PASSWORD
                  // =========================
                  CustomTextField(
                    controller: passwordController,
                    hintText: "Password",
                    prefixIcon: Icons.lock,
                    obscureText: true,

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  Align(
                    alignment: Alignment.centerRight,

                    child: TextButton(
                      onPressed: () {
                        // TODO: Forgot Password
                      },

                      child: const Text("Forgot Password?"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =========================
                  // LOGIN
                  // =========================
                  PrimaryButton(
                    text: isLoading ? "Please wait..." : "Login",
                    onPressed: isLoading ? () {} : login,
                  ),

                  const SizedBox(height: 15),

                  // =========================
                  // GOOGLE LOGIN
                  // =========================
                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : loginWithGoogle,

                      icon: const Icon(Icons.g_mobiledata, size: 30),

                      label: const Text("Continue with Google"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =========================
                  // GUEST LOGIN
                  // =========================
                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: OutlinedButton(
                      onPressed: isLoading ? null : loginAsGuest,

                      child: const Text("Continue as Guest"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =========================
                  // OR
                  // =========================
                  const Row(
                    children: [
                      Expanded(child: Divider()),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),

                        child: Text("OR"),
                      ),

                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // =========================
                  // SIGN UP
                  // =========================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      const Text("Don't have an account?"),

                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignupScreen(),
                                  ),
                                );
                              },

                        child: const Text("Sign Up"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
