
import 'package:flutter/material.dart';
import 'package:agrismart/models/zone.dart';
import 'package:agrismart/theme/app_theme.dart';

class ZoneCard extends StatelessWidget {
  final Zone zone;
  final VoidCallback onAugmenter;
  final VoidCallback onDiminuer;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ZoneCard({
    super.key,
    required this.zone,
    required this.onAugmenter,
    required this.onDiminuer,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final couleur =
    zone.besoinIrrigation ? AppTheme.echec : AppTheme.succes;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                child: Text(
                  zone.culture.length >= 4
                      ? zone.culture.substring(0, 4)
                      : zone.culture,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      diagnostic(zone),
                      style: TextStyle(color: couleur),
                    ),

                    const SizedBox(height: 4),

                    LinearProgressIndicator(
                      value: zone.humidite / 100,
                      color: couleur,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${zone.humidite.round()} %'),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: onDiminuer,
                        icon: const Icon(Icons.remove),
                      ),

                      IconButton(
                        onPressed: onAugmenter,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
