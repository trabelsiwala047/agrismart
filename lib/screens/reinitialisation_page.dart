
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class ReinitialisationPage extends StatefulWidget {
  const ReinitialisationPage({super.key});

  @override
  State<ReinitialisationPage> createState() =>
      _ReinitialisationPageState();
}

class _ReinitialisationPageState
    extends State<ReinitialisationPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _envoyerLien() async {
    final email = _emailController.text.trim();

    if (email.isEmpty ||
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir une adresse e-mail valide.'),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    await auth.reinitialiserMotDePasse(email);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          auth.erreur ?? 'Si cette adresse est enregistrée, un lien sera envoyé.',
        ),
      ),
    );

    if (auth.erreur == null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_reset,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              'Réinitialiser votre mot de passe',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Saisissez votre adresse e-mail pour recevoir un lien de réinitialisation.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Adresse e-mail',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: auth.chargement ? null : _envoyerLien,
                    child: auth.chargement
                        ? const CircularProgressIndicator()
                        : const Text('Envoyer le lien'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

