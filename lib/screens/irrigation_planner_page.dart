
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:agrismart/providers/zones_provider.dart';
import 'package:agrismart/models/zone.dart';

class IrrigationPlannerPage extends StatefulWidget {
  const IrrigationPlannerPage({super.key});

  @override
  State<IrrigationPlannerPage> createState() =>
      _IrrigationPlannerPageState();
}

class _IrrigationPlannerPageState
    extends State<IrrigationPlannerPage> {
  Zone? selectedZone;

  Color getPriorityColor(double deficit) {
    if (deficit <= 0) return Colors.green;
    if (deficit <= 10) return Colors.orange;
    if (deficit <= 25) return Colors.deepOrange;
    return Colors.red;
  }

  String getPriority(double deficit) {
    if (deficit <= 0) return 'Aucune urgence';
    if (deficit <= 10) return 'Faible';
    if (deficit <= 25) return 'Moyenne';
    return 'Élevée';
  }

  @override
  Widget build(BuildContext context) {
    final zones = context.watch<ZonesProvider>().zones;

    if (zones.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Smart Irrigation Planner')),
        body: const Center(
          child: Text('Aucune zone disponible'),
        ),
      );
    }

    final zone = zones.contains(selectedZone)
        ? selectedZone!
        : zones.first;

    final deficit =
    (zone.seuil - zone.humidite).clamp(0.0, 100.0);

    final besoin = zone.besoinIrrigation;

    final duration = besoin
        ? (deficit * 1.5).round().clamp(5, 30)
        : 0;

    final color = getPriorityColor(deficit);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Irrigation Planner'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Planification intelligente de l’irrigation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Analysez vos zones et obtenez des recommandations.',
            ),

            const SizedBox(height: 24),

            const Text(
              'Sélectionner une zone',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<Zone>(
              initialValue: zone,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.grass),
              ),
              items: zones.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item.nom),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedZone = value;
                });
              },
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Icon(
                      Icons.water_drop,
                      color: Colors.blue,
                      size: 45,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '${zone.humidite.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text('Humidité actuelle du sol'),

                    const SizedBox(height: 18),

                    LinearProgressIndicator(
                      value: (zone.humidite / 100).clamp(0.0, 1.0),
                      minHeight: 10,
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Seuil minimum'),
                        Text('${zone.seuil.toStringAsFixed(0)}%'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analyse intelligente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Expanded(child: Text('Déficit d’humidité')),
                        Text('${deficit.toStringAsFixed(0)}%'),
                      ],
                    ),

                    const Divider(),

                    Row(
                      children: [
                        const Expanded(child: Text('Priorité')),
                        Text(
                          getPriority(deficit),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Divider(),

                    Row(
                      children: [
                        const Expanded(
                          child: Text('Durée estimée'),
                        ),
                        Text(
                          besoin ? '$duration minutes' : 'Non nécessaire',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommandation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    besoin
                        ? 'La zone ${zone.nom} nécessite une irrigation. '
                        'Priorité : ${getPriority(deficit)}.'
                        : 'La zone ${zone.nom} possède une humidité suffisante.',
                  ),

                  if (besoin) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Durée indicative : $duration minutes.',
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Note : la durée est une estimation pédagogique, '
                  'pas un calcul agronomique précis. Vérifiez les conditions '
                  'météorologiques et les caractéristiques de votre terrain.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
