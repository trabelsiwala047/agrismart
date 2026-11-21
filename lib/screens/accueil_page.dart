import 'package:flutter/material.dart';
import 'package:agrismart/data/jeu_de_donnees.dart';
import 'package:agrismart/models/zone.dart';
import 'package:agrismart/screens/zone_detail_page.dart';
import 'package:agrismart/screens/zone_form_page.dart';
import 'package:agrismart/widgets/fiche_exploitation.dart';
import 'package:agrismart/widgets/resume_exploitation.dart';
import 'package:agrismart/widgets/zone_card.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  final List<Zone> _zones = jeuDeDonnees();

  void _modifierHumidite(Zone zone, double delta) {
    setState(() {
      zone.humidite = (zone.humidite + delta).clamp(0, 100).toDouble();
    });
  }

  Widget _carte(Zone zone) {
    return ZoneCard(
      zone: zone,
      onAugmenter: () => _modifierHumidite(zone, 5),
      onDiminuer: () => _modifierHumidite(zone, -5),
      onTap: () => _ouvrirDetail(zone),          // CHANGE : ouvre la fiche
      onLongPress: () => _confirmerSuppression(zone),
    );
  }

  // CHANGE : le formulaire est un ecran, uniquement pour l'ajout
  Future<void> _ouvrirFormulaire() async {
    final nouvelle = await Navigator.push<Zone>(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneFormPage(
          nomsExistants: _zones.map((z) => z.nom).toList(),
        ),
      ),
    );
    if (nouvelle == null || !mounted) return;
    setState(() => _zones.add(nouvelle));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zone ajoutée avec succès')),
    );
  }

  // NOUVEAU : ouvre la fiche de la zone
  Future<void> _ouvrirDetail(Zone zone) async {
    final modifiee = await Navigator.push<Zone>(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneDetailPage(
          zone: zone,
          nomsAutres:
          _zones.where((z) => z != zone).map((z) => z.nom).toList(),
        ),
      ),
    );
    if (modifiee == null || !mounted) return;
    setState(() {
      final index = _zones.indexOf(zone);
      if (index != -1) _zones[index] = modifiee;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zone modifiée avec succès')),
    );
  }

  Future<void> _confirmerSuppression(Zone zone) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Voulez-vous vraiment supprimer la zone "${zone.nom}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmation == true && mounted) {
      setState(() => _zones.remove(zone));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La zone "${zone.nom}" a été supprimée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('AgriSmart'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          FicheExploitation(humiditeMoyenne: humiditeMoyenne(_zones)),
          ResumeExploitation(zones: _zones),
          Expanded(
            child: _zones.isEmpty
                ? const Center(child: Text('Aucune zone pour le moment'))
                : LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 600) {
                  return GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: _zones.length,
                    itemBuilder: (context, index) => _carte(_zones[index]),
                  );
                }
                return ListView.separated(
                  itemCount: _zones.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) => _carte(_zones[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _ouvrirFormulaire,
        child: const Icon(Icons.add),
      ),
    );
  }
}