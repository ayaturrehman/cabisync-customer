// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/primary_button.dart';
import 'home/map_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            if (auth.isLoading)
              const CircularProgressIndicator()
            else
              PrimaryButton(
                text: "Login",
                onPressed: () async {
                  final success = await auth.login(
                    emailController.text,
                    passwordController.text,
                  );

                  if (!mounted) return;

                  if (success) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Login successful")),
                    );

                    // Navigate to home screen using MaterialPageRoute
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MapScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(auth.errorMessage ?? "Login failed"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
