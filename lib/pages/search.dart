import 'dart:async';

import 'package:annuaire_scolaire/services/data_service.dart';
import 'package:flutter/material.dart';
import '../model/etablissement.dart';
import 'search_results.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController = TextEditingController();

  String? _selectedDistrict;
  final List<String> _districts = [
    'AMBATOLAMPY',
    'ANTANIFOTSY',
    'ANTSIRABE I',
    'ANTSIRABE II',
    'BETAFO',
    'FARATSIHO',
    'MANDOTO',
  ];

  bool _isPrivate = false;
  bool _isPublic = false;
  bool _isTousSecteur = false;

  bool _isPrescolaire = false;
  bool _isNiveauI = false;
  bool _isNiveauII = false;
  bool _isNiveauIII = false;
  bool _isTous = false;

  List<Etablissement> _allEtablissements = [];

  void resetInterface() {
    if (!mounted) return;

    // Éviter les opérations coûteuses dans setState
    _searchController.clear();

    setState(() {
      _selectedDistrict = null;
      _isPrivate = false;
      _isPublic = false;
      _isTousSecteur = false;
      _isPrescolaire = false;
      _isNiveauI = false;
      _isNiveauII = false;
      _isNiveauIII = false;
      _isTous = false;
    });

    // Utiliser un timer pour le snackbar
    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Interface de recherche réinitialisée'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xff036B54),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadEtablissementsFromExcel();
  }

  Future<void> loadEtablissementsFromExcel() async {
    final etablissements = await DataService.getEtablissements();

    setState(() => _allEtablissements = etablissements);
  }

  void _onSearchPressed() {
    String searchText = _searchController.text.toLowerCase();

    // Vérifier si aucun filtre ni texte saisi
    bool noFilters =
        searchText.isEmpty &&
        (_selectedDistrict == null || _selectedDistrict!.isEmpty) &&
        !_isPrivate &&
        !_isPublic &&
        !_isTousSecteur &&
        !_isPrescolaire &&
        !_isNiveauI &&
        !_isNiveauII &&
        !_isNiveauIII &&
        !_isTous;

    if (noFilters) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez saisir dans la barre de recherche ou appliquer au moins un filtre, s'il vous plait !",
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return; // Ne pas continuer la recherche
    }

    // Préparer la liste des secteurs sélectionnés
    List<String> selectedSecteurs = [];
    if (_isTousSecteur) {
      // Lorsque "Tous" coché, inclure privée et publique
      selectedSecteurs = ['Privée', 'Publique'];
    } else {
      if (_isPrivate) selectedSecteurs.add('Privée');
      if (_isPublic) selectedSecteurs.add('Publique');
    }

    // Normaliser selectedSecteurs en minuscules
    List<String> selectedSecteursLower = selectedSecteurs
        .map((e) => e.toLowerCase())
        .toList();

    // Préparer la liste des niveaux sélectionnés sauf si "Tous" coché
    List<String> selectedNiveaux = [];
    if (!_isTous) {
      if (_isPrescolaire) selectedNiveaux.add('prescolaire');
      if (_isNiveauI) selectedNiveaux.add('niveau_I');
      if (_isNiveauII) selectedNiveaux.add('niveau_II');
      if (_isNiveauIII) selectedNiveaux.add('niveau_III');
    }

    // Normaliser selectedNiveaux en minuscules
    List<String> selectedNiveauxLower = selectedNiveaux
        .map((e) => e.toLowerCase())
        .toList();

    List<Etablissement> results = _allEtablissements.where((etab) {
      // Filtrer par texte (nom_etab)
      if (searchText.isNotEmpty &&
          !etab.nom_etab.toLowerCase().contains(searchText)) {
        return false;
      }

      // Filtrer par district Cisco si sélectionné
      if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) {
        if (etab.cisco.toLowerCase() != _selectedDistrict!.toLowerCase()) {
          return false;
        }
      }

      // Filtrer par secteur (doit correspondre à au moins un secteur sélectionné)
      if (selectedSecteursLower.isNotEmpty &&
          !selectedSecteursLower.contains(etab.secteur.toLowerCase())) {
        return false;
      }

      // Filtrer par niveau (si "Tous" coché, accepter tous niveaux)
      if (!_isTous &&
          selectedNiveauxLower.isNotEmpty &&
          !selectedNiveauxLower.contains(etab.niveau.toLowerCase())) {
        return false;
      }

      return true;
    }).toList();

    final futureResults = Future.value(results);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(futureResults: futureResults),
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedDistrict,
        isExpanded: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          border: InputBorder.none,
          hintText: 'Sélectionner un district',
        ),
        hint: const Text(
          'Sélectionner un district',
          style: TextStyle(fontFamily: 'Lato', color: Colors.grey),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        style: const TextStyle(
          fontFamily: 'Lato',
          color: Colors.black,
          fontSize: 16,
        ),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text(
              'Sélectionner un district',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ..._districts.map((String district) {
            return DropdownMenuItem<String>(
              value: district,
              child: Text(district),
            );
          }).toList(),
        ],
        onChanged: (String? newValue) {
          if (mounted) {
            setState(() {
              _selectedDistrict = newValue;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher...',
                      hintStyle: TextStyle(fontFamily: 'Lato'),
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'Lato'),
                  ),
                ),
                const SizedBox(height: 30.0),
                const Center(
                  child: Text(
                    'Plus de filtre',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'CISCO',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20.0),
                _buildDistrictDropdown(),
                const SizedBox(height: 30.0),
                const Text(
                  'Secteur',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _isPrivate,
                          onChanged: _isTousSecteur
                              ? null
                              : (bool? value) {
                                  setState(() {
                                    _isPrivate = value ?? false;
                                  });
                                },
                          activeColor: const Color(0xff036B54),
                          checkColor: Colors.white,
                        ),
                        const Text(
                          'Privée',
                          style: TextStyle(fontFamily: 'Lato', fontSize: 14),
                        ),
                        const SizedBox(width: 24.0),
                        Checkbox(
                          value: _isPublic,
                          onChanged: _isTousSecteur
                              ? null
                              : (bool? value) {
                                  setState(() {
                                    _isPublic = value ?? false;
                                  });
                                },
                          activeColor: const Color(0xff036B54),
                          checkColor: Colors.white,
                        ),
                        const Text(
                          'Public',
                          style: TextStyle(fontFamily: 'Lato', fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _isTousSecteur,
                          onChanged: (bool? value) {
                            setState(() {
                              _isTousSecteur = value ?? false;
                              if (_isTousSecteur) {
                                // Ne pas cocher Privée et Public mais les désactiver
                                _isPrivate = false;
                                _isPublic = false;
                              }
                            });
                          },
                          activeColor: const Color(0xff036B54),
                          checkColor: Colors.white,
                        ),
                        const Text(
                          'Tous',
                          style: TextStyle(fontFamily: 'Lato', fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                const Text(
                  'Niveaux',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _isPrescolaire,
                          onChanged: _isTous
                              ? null
                              : (bool? value) {
                                  setState(() {
                                    _isPrescolaire = value ?? false;
                                  });
                                },
                          activeColor: const Color(0xff036B54),
                          checkColor: Colors.white,
                        ),
                        const Text(
                          'Préscolaire',
                          style: TextStyle(fontFamily: 'Lato', fontSize: 14),
                        ),
                        const SizedBox(width: 40.0),
                        Checkbox(
                          value: _isNiveauI,
                          onChanged: _isTous
                              ? null
                              : (bool? value) {
                                  setState(() {
                                    _isNiveauI = value ?? false;
                                  });
                                },
                          activeColor: const Color(0xff036B54),
                          checkColor: Colors.white,
                        ),
                        const Text(
                          'Niveau I',
                          style: TextStyle(fontFamily: 'Lato', fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _isNiveauII,
                          onChanged: _isTous
                              ? null
                              : (bool? value) {
                                  setState(() {
                                    _isNiveauII = value ?? false;
                                  });
                                },
                          activeColor: const Color(0xff036B54),
                          checkColor: Colors.white,
                        ),
                        const Text(
                          'Niveau II',
                          style: TextStyle(fontFamily: 'Lato', fontSize: 14),
                        ),
                        const SizedBox(width: 55.0),
                        Checkbox(
                          value: _isNiveauIII,
                          onChanged: _isTous
                              ? null
                              : (bool? value) {
                                  setState(() {
                                    _isNiveauIII = value ?? false;
                                  });
                                },
                          activeColor: const Color(0xff036B54),
                          checkColor: Colors.white,
                        ),
                        const Text(
                          'Niveau III',
                          style: TextStyle(fontFamily: 'Lato', fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _isTous,
                          onChanged: (bool? value) {
                            setState(() {
                              _isTous = value ?? false;
                              if (_isTous) {
                                _isPrescolaire = false;
                                _isNiveauI = false;
                                _isNiveauII = false;
                                _isNiveauIII = false;
                              }
                            });
                          },
                          activeColor: const Color(0xff036B54),
                          checkColor: Colors.white,
                        ),
                        const Text(
                          'Tous',
                          style: TextStyle(fontFamily: 'Lato', fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _onSearchPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff036B54),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 12.0,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Rechercher'),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
