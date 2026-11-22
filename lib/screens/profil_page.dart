import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/reglages_provider.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthProvider, String>(
          (a) => a.utilisateur?.email ?? '',
    );

    // el thème el7ali (yetbaddel w el page tet3awed tetrasem)
    final themeMode = context.select<ReglagesProvider, ThemeMode>(
          (r) => r.themeMode,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 30),
          const CircleAvatar(
            radius: 45,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              email,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 30),

          // ---------- Choix du thème ----------
          const ListTile(
            leading: Icon(Icons.brightness_6),
            title: Text('Thème'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('Système'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Clair'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Sombre'),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (choix) {
                context.read<ReglagesProvider>().changerTheme(choix.first);
              },
            ),
          ),
          const SizedBox(height: 8),

          // ---------- Déconnexion ----------
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter'),
            onTap: () => _confirmerDeconnexion(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmerDeconnexion(BuildContext context) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (confirme != true || !context.mounted) return;

    await context.read<AuthProvider>().deconnexion();
  }
}