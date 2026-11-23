import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrismart/models/zone.dart';
import 'package:agrismart/providers/zones_provider.dart';
import 'package:agrismart/screens/zone_detail_page.dart';
import 'package:agrismart/screens/zone_form_page.dart';
import 'package:agrismart/widgets/fiche_exploitation.dart';
import 'package:agrismart/widgets/resume_exploitation.dart';
import 'package:agrismart/widgets/zone_card.dart';
import 'package:agrismart/screens/translation_screen.dart';
import 'package:agrismart/screens/scan_screen.dart';
import 'package:agrismart/screens/irrigation_map_page.dart';

class ZonesPage extends StatelessWidget {
  const ZonesPage({super.key});

  void _message(BuildContext context, String texte) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texte)));
  }

  Future<void> _ajouter(BuildContext context) async {
    final noms = context.read<ZonesProvider>().noms();
    final nouvelle = await Navigator.push<Zone>(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneFormPage(nomsExistants: noms),
      ),
    );
    if (nouvelle == null || !context.mounted) return;
    context.read<ZonesProvider>().ajouter(nouvelle);
    _message(context, 'Zone ajoutée');
  }

  Future<void> _ouvrirDetail(BuildContext context, Zone zone) async {
    final noms = context.read<ZonesProvider>().noms(sauf: zone);
    final modifiee = await Navigator.push<Zone>(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneDetailPage(zone: zone, nomsAutres: noms),
      ),
    );
    if (modifiee == null || !context.mounted) return;
    context.read<ZonesProvider>().remplacer(zone, modifiee);
    _message(context, 'Zone modifiée');
  }

  // NOUVEAU : ouvre l'écran de traduction
  void _ouvrirTraduction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TranslationScreen()),
    );
  }

  // NOUVEAU : ouvre la carte agricole
  void _ouvrirCarte(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IrrigationMapPage()),
    );
  }

  // NOUVEAU : scanne un QR code (contenu = nom de la zone) et ouvre la zone
  Future<void> _scannerZone(BuildContext context) async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    if (code == null || !context.mounted) return;

    final texte = code.trim().toLowerCase();
    final provider = context.read<ZonesProvider>();
    Zone? trouvee;
    for (final z in provider.zones) {
      if (z.nom.trim().toLowerCase() == texte) {
        trouvee = z;
        break;
      }
    }

    if (trouvee == null) {
      _message(context, 'Aucune zone trouvée pour : $code');
      return;
    }

    _ouvrirDetail(context, trouvee);
  }

  Future<void> _confirmerSuppression(BuildContext context, Zone zone) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la zone ?'),
        content: Text('« ${zone.nom} » sera supprimée.'),
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
      ),
    );
    if (confirme != true || !context.mounted) return;
    context.read<ZonesProvider>().supprimer(zone);
    _message(context, 'Zone supprimée');
  }

  Widget _carte(BuildContext context, Zone zone) {
    final provider = context.read<ZonesProvider>();
    return ZoneCard(
      zone: zone,
      onAugmenter: () => provider.modifierHumidite(zone, 5),
      onDiminuer: () => provider.modifierHumidite(zone, -5),
      onTap: () => _ouvrirDetail(context, zone),
      onLongPress: () => _confirmerSuppression(context, zone),
    );
  }

  @override
  Widget build(BuildContext context) {
    // watch : on affiche des données
    final provider = context.watch<ZonesProvider>();
    final toutes = provider.zones; // pour le bandeau (toutes les zones)
    final zones = provider.zonesAffichees; // pour la liste (filtrée ou non)

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('AgriSmart'),
        actions: [
          // NOUVEAU : bouton carte
          IconButton(
            tooltip: 'Carte agricole',
            icon: const Icon(Icons.map),
            onPressed: () => _ouvrirCarte(context),
          ),
          // NOUVEAU : bouton scan
          IconButton(
            tooltip: 'Scanner une zone',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _scannerZone(context),
          ),
          // NOUVEAU : bouton traduction
          IconButton(
            tooltip: 'Traduction',
            icon: const Icon(Icons.translate),
            onPressed: () => _ouvrirTraduction(context),
          ),
          // Exercice 1 : filtre (read dans onPressed)
          IconButton(
            tooltip: 'Zones à irriguer',
            onPressed: () => context.read<ZonesProvider>().basculerFiltre(),
            icon: Icon(
              provider.seulementAIrriguer
                  ? Icons.filter_alt
                  : Icons.filter_alt_off,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          FicheExploitation(humiditeMoyenne: provider.humiditeMoyenne),
          ResumeExploitation(zones: toutes),
          Expanded(
            child: zones.isEmpty
                ? const Center(child: Text('Aucune zone à afficher'))
                : LayoutBuilder(
              builder: (context, constraints) {
                // grand écran : grille
                if (constraints.maxWidth > 600) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: zones.length,
                    itemBuilder: (context, index) =>
                        _carte(context, zones[index]),
                  );
                }
                // petit écran : liste
                return ListView.separated(
                  itemCount: zones.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 4),
                  itemBuilder: (context, index) =>
                      _carte(context, zones[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _ajouter(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}