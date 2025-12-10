// result_details.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:annuaire_scolaire/services/connectivity_service.dart';
import 'package:annuaire_scolaire/services/widget_builder_service.dart';

class ResultDetailsPage extends StatefulWidget {
  final String secteur;
  final String niveau;
  final String cisco;
  final String commune;
  final String fokontany;
  final String nom_etab;
  final double x;
  final double y;
  final String resultat;
  final String nombre_enseignant_non_fonctionnaire;
  final String nombre_enseignant_fonctionnaire;
  final String nombre_personel_administratif_non_fonctionnaire;
  final String nombre_personel_administratif_fonctionnaire;
  final String nombre_benevoles;
  final String effectif_total_personnel;
  final String diplome_LAPEN;
  final String diplome_MAPEN;
  final String diplome_BAC;
  final String diplome_BTS;
  final String diplome_M1;
  final String diplome_M2;
  final String diplome_INGENIEUR;
  final String diplome_DEA;
  final String diplome_DOCTORAT;
  final String diplome_Inferieur_BACC;
  final String nom_prenom_directeur;
  final String contact_directeur;
  final String adresse_etablissement;
  final String nombre_classe_petite_section;
  final String nombre_classe_moyenne_section;
  final String nombre_classe_grande_section;
  final String nombre_classe_12em;
  final String nombre_classe_11em;
  final String nombre_classe_10em;
  final String nombre_classe_9em;
  final String nombre_classe_8em;
  final String nombre_classe_7em;
  final String nombre_classe_6em;
  final String nombre_classe_5em;
  final String nombre_classe_4em;
  final String nombre_classe_3em;
  final String nombre_classe_seconde;
  final String nombre_classe_premiere_A;
  final String nombre_classe_premiere_C;
  final String nombre_classe_premiere_D;
  final String nombre_classe_premiere_L;
  final String nombre_classe_premiere_Ose;
  final String nombre_classe_premiere_S;
  final String nombre_classe_premiere_total;
  final String nombre_classe_terminale_A;
  final String nombre_classe_terminale_C;
  final String nombre_classe_terminale_D;
  final String nombre_classe_terminale_L;
  final String nombre_classe_terminale_S;
  final String nombre_classe_terminale_Ose;
  final String nombre_classe_terminale_total;
  final String taux_bacc_A1;
  final String taux_bacc_A2;
  final String taux_bacc_C;
  final String taux_bacc_D;
  final String taux_bacc_L;
  final String taux_bacc_Ose;
  final String taux_bacc_S;

  const ResultDetailsPage({
    super.key,
    required this.secteur,
    required this.niveau,
    required this.cisco,
    required this.commune,
    required this.fokontany,
    required this.nom_etab,
    required this.x,
    required this.y,
    required this.resultat,
    required this.nombre_enseignant_non_fonctionnaire,
    required this.nombre_enseignant_fonctionnaire,
    required this.nombre_personel_administratif_non_fonctionnaire,
    required this.nombre_personel_administratif_fonctionnaire,
    required this.nombre_benevoles,
    required this.effectif_total_personnel,
    required this.diplome_LAPEN,
    required this.diplome_MAPEN,
    required this.diplome_BAC,
    required this.diplome_BTS,
    required this.diplome_M1,
    required this.diplome_M2,
    required this.diplome_INGENIEUR,
    required this.diplome_DEA,
    required this.diplome_DOCTORAT,
    required this.diplome_Inferieur_BACC,
    required this.nom_prenom_directeur,
    required this.contact_directeur,
    required this.adresse_etablissement,
    required this.nombre_classe_petite_section,
    required this.nombre_classe_moyenne_section,
    required this.nombre_classe_grande_section,
    required this.nombre_classe_12em,
    required this.nombre_classe_11em,
    required this.nombre_classe_10em,
    required this.nombre_classe_9em,
    required this.nombre_classe_8em,
    required this.nombre_classe_7em,
    required this.nombre_classe_6em,
    required this.nombre_classe_5em,
    required this.nombre_classe_4em,
    required this.nombre_classe_3em,
    required this.nombre_classe_seconde,
    required this.nombre_classe_premiere_A,
    required this.nombre_classe_premiere_C,
    required this.nombre_classe_premiere_D,
    required this.nombre_classe_premiere_L,
    required this.nombre_classe_premiere_Ose,
    required this.nombre_classe_premiere_S,
    required this.nombre_classe_premiere_total,
    required this.nombre_classe_terminale_A,
    required this.nombre_classe_terminale_C,
    required this.nombre_classe_terminale_D,
    required this.nombre_classe_terminale_L,
    required this.nombre_classe_terminale_S,
    required this.nombre_classe_terminale_Ose,
    required this.nombre_classe_terminale_total,
    required this.taux_bacc_A1,
    required this.taux_bacc_A2,
    required this.taux_bacc_C,
    required this.taux_bacc_D,
    required this.taux_bacc_L,
    required this.taux_bacc_Ose,
    required this.taux_bacc_S,
  });

  @override
  _ResultDetailsPageState createState() => _ResultDetailsPageState();
}

class _ResultDetailsPageState extends State<ResultDetailsPage> {
  bool isQualiteExpanded = false;
  bool isDiplomeExpanded = false;
  bool isSectionsExpanded = false;
  bool isTauxBacExpanded = false;
  late LatLng position;
  bool isOnline = true;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    position = LatLng(widget.y, widget.x);
    _checkConnection();
    Connectivity().onConnectivityChanged.listen((result) {
      ConnectivityService.updateConnectionStatus(
        result.first,
        (status) => setState(() => isOnline = status),
      );
    });
  }

  Future<void> _checkConnection() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    bool connected = !connectivityResults.contains(ConnectivityResult.none);
    ConnectivityService.updateConnectionStatus(
      connected ? ConnectivityResult.wifi : ConnectivityResult.none,
      (status) => setState(() => isOnline = status),
    );
  }

  Future<void> _refreshConnection() async {
    await ConnectivityService.refreshConnection(
      setRefreshing: (refreshing) => setState(() => isRefreshing = refreshing),
      setOnline: (online) => setState(() => isOnline = online),
      checkConnection: _checkConnection,
    );
  }

  Widget _buildMapSection() {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isOnline
            ? FlutterMap(
                options: MapOptions(initialCenter: position, initialZoom: 15),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.annuaire_scolaire',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: position,
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_pin,
                          color: Color.fromARGB(255, 2, 103, 2),
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : WidgetBuilderService.buildOfflineMap(
                isRefreshing: isRefreshing,
                onRefresh: _refreshConnection,
              ),
      ),
    );
  }

  Widget _buildQualitePersonnelSection() {
    return Column(
      children: [
        WidgetBuilderService.buildSectionHeader(
          title: "Qualité du personnels",
          isExpanded: isQualiteExpanded,
          onToggle: () =>
              setState(() => isQualiteExpanded = !isQualiteExpanded),
        ),
        WidgetBuilderService.buildAnimatedSection(
          isExpanded: isQualiteExpanded,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WidgetBuilderService.buildPersonnelItem(
                  title: "Enseignants non-fonctionnaires",
                  value: widget.nombre_enseignant_non_fonctionnaire,
                  isFirst: true,
                ),
                WidgetBuilderService.buildDivider(),
                WidgetBuilderService.buildPersonnelItem(
                  title: "Enseignants fonctionnaires",
                  value: widget.nombre_enseignant_fonctionnaire,
                ),
                WidgetBuilderService.buildDivider(),
                WidgetBuilderService.buildPersonnelItem(
                  title: "Personnel administratif non-fonctionnaires",
                  value: widget.nombre_personel_administratif_non_fonctionnaire,
                ),
                WidgetBuilderService.buildDivider(),
                WidgetBuilderService.buildPersonnelItem(
                  title: "Personnel administratif fonctionnaires",
                  value: widget.nombre_personel_administratif_fonctionnaire,
                ),
                WidgetBuilderService.buildDivider(),
                WidgetBuilderService.buildPersonnelItem(
                  title: "Nombre de bénévoles",
                  value: widget.nombre_benevoles,
                ),
                WidgetBuilderService.buildDivider(),
                const SizedBox(height: 10),
                WidgetBuilderService.buildEffectifTotal(
                  title: "Effectif total",
                  value: widget.effectif_total_personnel,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiplomesSection() {
    return Column(
      children: [
        WidgetBuilderService.buildSectionHeader(
          title: "Statistiques des diplômes des enseignants",
          isExpanded: isDiplomeExpanded,
          onToggle: () =>
              setState(() => isDiplomeExpanded = !isDiplomeExpanded),
        ),
        WidgetBuilderService.buildAnimatedSection(
          isExpanded: isDiplomeExpanded,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WidgetBuilderService.buildDiplomeItem(
                  title: "Diplômes LAPEN",
                  value: widget.diplome_LAPEN,
                  isFirst: true,
                ),
                WidgetBuilderService.buildDivider(),
                WidgetBuilderService.buildDiplomeItem(
                  title: "Diplômes MAPEN",
                  value: widget.diplome_MAPEN,
                ),
                WidgetBuilderService.buildDivider(),
                WidgetBuilderService.buildDiplomeItem(
                  title: "Diplômes BAC",
                  value: widget.diplome_BAC,
                ),
                WidgetBuilderService.buildDivider(),
                WidgetBuilderService.buildDiplomeItem(
                  title: "Diplômes BTS",
                  value: widget.diplome_BTS,
                ),
                WidgetBuilderService.buildDivider(),
                WidgetBuilderService.buildDiplomeItem(
                  title: "Diplômes M1",
                  value: widget.diplome_M1,
                ),
                WidgetBuilderService.buildDivider(),
                WidgetBuilderService.buildDiplomeItem(
                  title: "Diplômes M2",
                  value: widget.diplome_M2,
                ),
                WidgetBuilderService.buildDivider(),
                WidgetBuilderService.buildDiplomeItem(
                  title: "Diplômes INGENIEUR",
                  value: widget.diplome_INGENIEUR,
                ),
                WidgetBuilderService.buildDivider(),
                WidgetBuilderService.buildDiplomeItem(
                  title: "Diplômes DEA",
                  value: widget.diplome_DEA,
                ),
                WidgetBuilderService.buildDivider(),
                WidgetBuilderService.buildDiplomeItem(
                  title: "Diplômes DOCTORAT",
                  value: widget.diplome_DOCTORAT,
                ),
                WidgetBuilderService.buildDivider(),
                WidgetBuilderService.buildDiplomeItem(
                  title: "Diplômes Inférieur BACC",
                  value: widget.diplome_Inferieur_BACC,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionsParClasse() {
    return Column(
      children: [
        WidgetBuilderService.buildSectionHeader(
          title: "Nombre de sections par classe",
          isExpanded: isSectionsExpanded,
          onToggle: () =>
              setState(() => isSectionsExpanded = !isSectionsExpanded),
        ),
        WidgetBuilderService.buildAnimatedSection(
          isExpanded: isSectionsExpanded,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildSectionsContent(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSectionsContent() {
    final List<Widget> sections = [];

    // NIVEAU PRÉSCOLAIRE
    if (widget.niveau.toLowerCase() == 'prescolaire') {
      _addSectionIfValid(
        sections,
        "Petite section",
        widget.nombre_classe_petite_section,
      );
      _addSectionIfValid(
        sections,
        "Moyenne section",
        widget.nombre_classe_moyenne_section,
      );
      _addSectionIfValid(
        sections,
        "Grande section",
        widget.nombre_classe_grande_section,
      );
    }
    // NIVEAU I (12ème à 7ème)
    else if (widget.niveau.toLowerCase() == 'niveau_i') {
      _addSectionIfValid(sections, "12ème", widget.nombre_classe_12em);
      _addSectionIfValid(sections, "11ème", widget.nombre_classe_11em);
      _addSectionIfValid(sections, "10ème", widget.nombre_classe_10em);
      _addSectionIfValid(sections, "9ème", widget.nombre_classe_9em);
      _addSectionIfValid(sections, "8ème", widget.nombre_classe_8em);
      _addSectionIfValid(sections, "7ème", widget.nombre_classe_7em);
    }
    // NIVEAU II (6ème à 3ème)
    else if (widget.niveau.toLowerCase() == 'niveau_ii') {
      _addSectionIfValid(sections, "6ème", widget.nombre_classe_6em);
      _addSectionIfValid(sections, "5ème", widget.nombre_classe_5em);
      _addSectionIfValid(sections, "4ème", widget.nombre_classe_4em);
      _addSectionIfValid(sections, "3ème", widget.nombre_classe_3em);
    }
    // NIVEAU III (Seconde, Premières, Terminales)
    else if (widget.niveau.toLowerCase() == 'niveau_iii') {
      _addSectionIfValid(sections, "Seconde", widget.nombre_classe_seconde);
      _addSectionIfValid(
        sections,
        "Première A",
        widget.nombre_classe_premiere_A,
      );
      _addSectionIfValid(
        sections,
        "Première C",
        widget.nombre_classe_premiere_C,
      );
      _addSectionIfValid(
        sections,
        "Première D",
        widget.nombre_classe_premiere_D,
      );
      _addSectionIfValid(
        sections,
        "Première L",
        widget.nombre_classe_premiere_L,
      );
      _addSectionIfValid(
        sections,
        "Première OSE",
        widget.nombre_classe_premiere_Ose,
      );
      _addSectionIfValid(
        sections,
        "Première S",
        widget.nombre_classe_premiere_S,
      );

      if (_isValidValue(widget.nombre_classe_premiere_total)) {
        sections.add(
          WidgetBuilderService.buildSectionItem(
            title: "Total Premières",
            value: widget.nombre_classe_premiere_total,
            isTotal: true,
          ),
        );
      }

      _addSectionIfValid(
        sections,
        "Terminale A",
        widget.nombre_classe_terminale_A,
      );
      _addSectionIfValid(
        sections,
        "Terminale C",
        widget.nombre_classe_terminale_C,
      );
      _addSectionIfValid(
        sections,
        "Terminale D",
        widget.nombre_classe_terminale_D,
      );
      _addSectionIfValid(
        sections,
        "Terminale L",
        widget.nombre_classe_terminale_L,
      );
      _addSectionIfValid(
        sections,
        "Terminale OSE",
        widget.nombre_classe_terminale_Ose,
      );
      _addSectionIfValid(
        sections,
        "Terminale S",
        widget.nombre_classe_terminale_S,
      );

      if (_isValidValue(widget.nombre_classe_terminale_total)) {
        sections.add(
          WidgetBuilderService.buildSectionItem(
            title: "Total Terminales",
            value: widget.nombre_classe_terminale_total,
            isTotal: true,
          ),
        );
      }
    }
    // CAS PAR DÉFAUT
    else {
      sections.add(
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Aucune information disponible pour ce niveau",
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 16,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return sections;
  }

  void _addSectionIfValid(List<Widget> sections, String title, String value) {
    if (_isValidValue(value)) {
      if (sections.isNotEmpty) {
        sections.add(WidgetBuilderService.buildDivider());
      }
      sections.add(
        WidgetBuilderService.buildSectionItem(title: title, value: value),
      );
    }
  }

  bool _isValidValue(String value) {
    return value.isNotEmpty && value != "0";
  }

  Widget _buildTauxBacSection() {
    if (widget.niveau.toLowerCase() != 'niveau_iii') {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        WidgetBuilderService.buildSectionHeader(
          title: "Taux de résultats de BAC pour chaque série",
          isExpanded: isTauxBacExpanded,
          onToggle: () =>
              setState(() => isTauxBacExpanded = !isTauxBacExpanded),
        ),
        WidgetBuilderService.buildAnimatedSection(
          isExpanded: isTauxBacExpanded,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildTauxBacContent(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTauxBacContent() {
    final List<Widget> tauxItems = [];

    _addTauxIfValid(tauxItems, "BAC Série A1", widget.taux_bacc_A1, true);
    _addTauxIfValid(tauxItems, "BAC Série A2", widget.taux_bacc_A2);
    _addTauxIfValid(tauxItems, "BAC Série C", widget.taux_bacc_C);
    _addTauxIfValid(tauxItems, "BAC Série D", widget.taux_bacc_D);
    _addTauxIfValid(tauxItems, "BAC Série L", widget.taux_bacc_L);
    _addTauxIfValid(tauxItems, "BAC Série OSE", widget.taux_bacc_Ose);
    _addTauxIfValid(tauxItems, "BAC Série S", widget.taux_bacc_S);

    return tauxItems;
  }

  void _addTauxIfValid(
    List<Widget> tauxItems,
    String title,
    String value, [
    bool isFirst = false,
  ]) {
    if (_isValidValue(value)) {
      if (tauxItems.isNotEmpty) {
        tauxItems.add(WidgetBuilderService.buildDivider());
      }
      tauxItems.add(
        WidgetBuilderService.buildTauxBacItem(
          title: title,
          value: value,
          isFirst: isFirst,
        ),
      );
    }
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                "Plus d'informations et contact",
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: const Color(0xff036B54).withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WidgetBuilderService.buildContactInfoItem(
                context: context,
                icon: Icons.home,
                value: widget.adresse_etablissement,
              ),
              WidgetBuilderService.buildDivider(),
              WidgetBuilderService.buildContactInfoItem(
                context: context,
                icon: Icons.person,
                value: widget.nom_prenom_directeur,
              ),
              WidgetBuilderService.buildDivider(),
              WidgetBuilderService.buildContactInfoItem(
                context: context,
                icon: Icons.phone,
                value: widget.contact_directeur,
                isPhone: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff036B54),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Détails',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMapSection(),
            const SizedBox(height: 20),
            WidgetBuilderService.buildSchoolInfo(
              nomEtab: widget.nom_etab,
              niveau: widget.niveau,
              secteur: widget.secteur,
              cisco: widget.cisco,
              commune: widget.commune,
              fokontany: widget.fokontany,
            ),
            WidgetBuilderService.buildResultWidget(
              niveau: widget.niveau,
              resultat: widget.resultat,
            ),
            const SizedBox(height: 25),
            _buildQualitePersonnelSection(),
            const SizedBox(height: 10),
            _buildDiplomesSection(),
            const SizedBox(height: 10),
            _buildSectionsParClasse(),
            const SizedBox(height: 10),
            _buildTauxBacSection(),
            const SizedBox(height: 16),
            _buildContactSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
