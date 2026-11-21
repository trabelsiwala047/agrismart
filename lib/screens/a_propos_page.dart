import 'package:flutter/material.dart';

// Exercice 2 : page "A propos"
class AProposPage extends StatelessWidget {
  const AProposPage({super.key});

  @override
  Widget build(BuildContext context) {
    final texte = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AgriSmart', style: texte.headlineMedium),
            const SizedBox(height: 8),
            Text('Version 1.0.0', style: texte.titleMedium),
            const SizedBox(height: 16),
            const Text(
              "AgriSmart permet de suivre l'humidité des zones d'une "
                  "exploitation agricole et de décider quand irriguer. "
                  "Projet Smart Agriculture - ISET Kébili.",
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
