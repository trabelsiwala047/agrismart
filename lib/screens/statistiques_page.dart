import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrismart/providers/zones_provider.dart';
import 'package:agrismart/theme/app_theme.dart';
import 'package:agrismart/widgets/meteo_card.dart';
import 'package:agrismart/widgets/resume_exploitation.dart';

class StatistiquesPage extends StatelessWidget {
  const StatistiquesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // toujours TOUTES les zones, même si le filtre est actif dans l'onglet Zones
    final zones = context.watch<ZonesProvider>().zones;

    final tri = [...zones]..sort((a, b) => a.humidite.compareTo(b.humidite));
    final aIrriguer = zones.where((z) => z.besoinIrrigation).length;
    final pourcentage =
    zones.isEmpty ? 0 : (aIrriguer * 100 / zones.length).round();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Statistiques'),
      ),
      body: ListView(
        children: [
          const MeteoCard(),
          if (zones.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Aucune donnée à afficher')),
            )
          else ...[
            ResumeExploitation(zones: zones),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '$aIrriguer zone(s) sur ${zones.length} à irriguer '
                    '($pourcentage %)',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Humidité par zone',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final z in tri)
              ListTile(
                title: Text(z.nom),
                subtitle: LinearProgressIndicator(
                  value: z.humidite / 100,
                  color: z.besoinIrrigation
                      ? AppTheme.echec
                      : AppTheme.succes,
                ),
                trailing: Text('${z.humidite.toStringAsFixed(0)} %'),
              ),
          ],
        ],
      ),
    );
  }
}