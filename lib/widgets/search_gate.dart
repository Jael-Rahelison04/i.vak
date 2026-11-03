import 'package:flutter/material.dart';
import 'package:annuaire_scolaire/services/data_service.dart';
import 'package:annuaire_scolaire/widgets/year_selection_dialog.dart';
import 'package:annuaire_scolaire/pages/search.dart';
import '../model/etablissement.dart';

class SearchGate extends StatefulWidget {
  final GlobalKey<SearchPageState> searchPageKey;

  const SearchGate({super.key, required this.searchPageKey});

  @override
  State<SearchGate> createState() => _SearchGateState();
}

class _SearchGateState extends State<SearchGate> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Etablissement>>(
      future: DataService.getEtablissements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xff036B54)),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final etablissements = snapshot.data ?? [];

        if (etablissements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_download, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Aucune donnée disponible'),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Télécharger des données'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff036B54),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (_) => YearSelectionDialog(
                        onDataChanged: () => setState(() {}),
                      ),
                    );
                    if (result == true) setState(() {}); // recharge
                  },
                ),
              ],
            ),
          );
        }

        // ✅ Données présentes → afficher la page de recherche
        return SearchPage(key: widget.searchPageKey);
      },
    );
  }
}
