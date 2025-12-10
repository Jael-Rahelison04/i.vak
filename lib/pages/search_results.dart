import 'package:flutter/material.dart';
import '../model/etablissement.dart';
import 'result_details.dart';

class SearchResultsPage extends StatelessWidget {
  final Future<List<Etablissement>> futureResults;

  const SearchResultsPage({super.key, required this.futureResults});

  String formatNiveau(String niveau) {
    switch (niveau.toLowerCase()) {
      case 'prescolaire':
        return 'Préscolaire';
      case 'niveau_i':
        return 'Niveau I';
      case 'niveau_ii':
        return 'Niveau II';
      case 'niveau_iii':
        return 'Niveau III';
      default:
        return niveau;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff036B54),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Résultats',
          style: TextStyle(
            fontFamily: 'Lato',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Etablissement>>(
        future: futureResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else {
            final results = snapshot.data ?? [];
            if (results.isEmpty) {
              return const Center(child: Text('Aucun résultat trouvé'));
            }
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.nom_etab,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Niveau : ${formatNiveau(item.niveau)}',
                                      style: const TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Secteur : ${item.secteur}',
                                      style: const TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ResultDetailsPage(
                                        nom_etab: item.nom_etab,
                                        secteur: item.secteur,
                                        niveau: item.niveau,
                                        cisco: item.cisco,
                                        commune: item.commune,
                                        resultat: item.resultat,
                                        fokontany: item.fokontany,
                                        x: item.x,
                                        y: item.y,
                                        nombre_enseignant_non_fonctionnaire: item
                                            .nombre_enseignant_non_fonctionnaire,
                                        nombre_enseignant_fonctionnaire: item
                                            .nombre_enseignant_fonctionnaire,
                                        nombre_personel_administratif_non_fonctionnaire:
                                            item.nombre_personel_administratif_non_fonctionnaire,
                                        nombre_personel_administratif_fonctionnaire:
                                            item.nombre_personel_administratif_fonctionnaire,
                                        nombre_benevoles: item.nombre_benevoles,
                                        effectif_total_personnel:
                                            item.effectif_total_personnel,
                                        diplome_LAPEN: item.diplome_LAPEN,
                                        diplome_MAPEN: item.diplome_MAPEN,
                                        diplome_BAC: item.diplome_BAC,
                                        diplome_BTS: item.diplome_BTS,
                                        diplome_M1: item.diplome_M1,
                                        diplome_M2: item.diplome_M2,
                                        diplome_INGENIEUR:
                                            item.diplome_INGENIEUR,
                                        diplome_DEA: item.diplome_DEA,
                                        diplome_DOCTORAT: item.diplome_DOCTORAT,
                                        diplome_Inferieur_BACC:
                                            item.diplome_Inferieur_BACC,
                                        nom_prenom_directeur:
                                            item.nom_prenom_directeur,
                                        contact_directeur:
                                            item.contact_directeur,
                                        adresse_etablissement:
                                            item.adresse_etablissement,
                                        nombre_classe_petite_section:
                                            item.nombre_classe_petite_section,
                                        nombre_classe_moyenne_section:
                                            item.nombre_classe_moyenne_section,
                                        nombre_classe_grande_section:
                                            item.nombre_classe_grande_section,
                                        nombre_classe_12em:
                                            item.nombre_classe_12em,
                                        nombre_classe_11em:
                                            item.nombre_classe_11em,
                                        nombre_classe_10em:
                                            item.nombre_classe_10em,
                                        nombre_classe_9em:
                                            item.nombre_classe_9em,
                                        nombre_classe_8em:
                                            item.nombre_classe_8em,
                                        nombre_classe_7em:
                                            item.nombre_classe_7em,
                                        nombre_classe_6em:
                                            item.nombre_classe_6em,
                                        nombre_classe_5em:
                                            item.nombre_classe_5em,
                                        nombre_classe_4em:
                                            item.nombre_classe_4em,
                                        nombre_classe_3em:
                                            item.nombre_classe_3em,
                                        nombre_classe_seconde:
                                            item.nombre_classe_seconde,
                                        nombre_classe_premiere_A:
                                            item.nombre_classe_premiere_A,
                                        nombre_classe_premiere_C:
                                            item.nombre_classe_premiere_C,
                                        nombre_classe_premiere_D:
                                            item.nombre_classe_premiere_D,
                                        nombre_classe_premiere_L:
                                            item.nombre_classe_premiere_L,
                                        nombre_classe_premiere_Ose:
                                            item.nombre_classe_premiere_Ose,
                                        nombre_classe_premiere_S:
                                            item.nombre_classe_premiere_S,
                                        nombre_classe_premiere_total:
                                            item.nombre_classe_premiere_total,
                                        nombre_classe_terminale_A:
                                            item.nombre_classe_terminale_A,
                                        nombre_classe_terminale_C:
                                            item.nombre_classe_terminale_C,
                                        nombre_classe_terminale_D:
                                            item.nombre_classe_terminale_D,
                                        nombre_classe_terminale_L:
                                            item.nombre_classe_terminale_L,
                                        nombre_classe_terminale_S:
                                            item.nombre_classe_terminale_S,
                                        nombre_classe_terminale_Ose:
                                            item.nombre_classe_terminale_Ose,
                                        nombre_classe_terminale_total:
                                            item.nombre_classe_terminale_total,
                                        taux_bacc_A1: item.taux_bacc_A1,
                                        taux_bacc_A2: item.taux_bacc_A2,
                                        taux_bacc_C: item.taux_bacc_C,
                                        taux_bacc_D: item.taux_bacc_D,
                                        taux_bacc_L: item.taux_bacc_L,
                                        taux_bacc_Ose: item.taux_bacc_Ose,
                                        taux_bacc_S: item.taux_bacc_S,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff036B54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'Détails',
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
