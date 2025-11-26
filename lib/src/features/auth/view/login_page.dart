import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Smart Tank Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            auth.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      // Capture navigator and messenger BEFORE the async gap
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      final success = await auth.login(
                        emailCtrl.text.trim(),
                        passwordCtrl.text.trim(),
                      );

                      if (!mounted) return;

                      if (success) {
                        navigator.pushReplacementNamed("/dashboard");
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(content: Text("Login failed")),
                        );
                      }
                    },
                    child: const Text("Login"),
                  )
          ],
        ),
      ),
    );
  }
}
