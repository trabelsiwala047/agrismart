
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:agrismart/models/zone.dart';
import 'package:agrismart/providers/zones_provider.dart';

class IrrigationMapPage extends StatefulWidget {
  const IrrigationMapPage({super.key});

  @override
  State<IrrigationMapPage> createState() =>
      _IrrigationMapPageState();
}

class _IrrigationMapPageState extends State<IrrigationMapPage> {
  int selectedIndex = 0;

  // Coordonnées fictives pour la démonstration à Kébili.
  final List<LatLng> positions = [
    LatLng(33.7040, 8.9690),
    LatLng(33.7100, 8.9800),
    LatLng(33.6960, 8.9820),
    LatLng(33.7150, 8.9550),
    LatLng(33.6900, 8.9600),
  ];

  LatLng getPosition(int index) {
    if (index < positions.length) {
      return positions[index];
    }

    return LatLng(
      33.7040 + index * 0.003,
      8.9690 + index * 0.003,
    );
  }

  Color getColor(Zone zone) {
    final deficit =
    (zone.seuil - zone.humidite).clamp(0.0, 100.0);

    if (deficit <= 0) return Colors.green;
    if (deficit <= 10) return Colors.orange;
    if (deficit <= 25) return Colors.deepOrange;
    return Colors.red;
  }

  String getPriority(Zone zone) {
    final deficit =
    (zone.seuil - zone.humidite).clamp(0.0, 100.0);

    if (deficit <= 0) return 'Normale';
    if (deficit <= 10) return 'Faible';
    if (deficit <= 25) return 'Moyenne';
    return 'Élevée';
  }

  @override
  Widget build(BuildContext context) {
    final zones = context.watch<ZonesProvider>().zones;

    if (zones.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carte agricole')),
        body: const Center(
          child: Text('Aucune zone disponible'),
        ),
      );
    }

    if (selectedIndex >= zones.length) {
      selectedIndex = 0;
    }

    final zone = zones[selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte agricole'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  '${zones.length} zones agricoles',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: getPosition(selectedIndex),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'tn.isetkebili.agrismart',
                ),

                MarkerLayer(
                  markers: List.generate(zones.length, (index) {
                    final item = zones[index];

                    return Marker(
                      point: getPosition(index),
                      width: 100,
                      height: 75,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: getColor(item),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.nom,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.location_on,
                              size: 35,
                              color: getColor(item),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.nom,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text('Culture : ${zone.culture}'),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    _info(
                      'Humidité',
                      '${zone.humidite.toStringAsFixed(0)}%',
                    ),
                    _info(
                      'Seuil',
                      '${zone.seuil.toStringAsFixed(0)}%',
                    ),
                    _info(
                      'Priorité',
                      getPriority(zone),
                      getColor(zone),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  zone.besoinIrrigation
                      ? 'Cette zone nécessite une irrigation.'
                      : 'Humidité suffisante.',
                  style: TextStyle(
                    color: getColor(zone),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String title, String value, [Color? color]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
