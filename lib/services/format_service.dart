class FormatService {
  static String formatNiveau(String niveau) {
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

  static String formatResultat(String rawResultat) {
    try {
      double value = double.parse(rawResultat);
      return "${(value * 100).toStringAsFixed(2)} %";
    } catch (e) {
      return rawResultat;
    }
  }

  static String formatTauxBac(String taux) {
    try {
      double value = double.parse(taux);
      return "${(value * 100).toStringAsFixed(2)} %";
    } catch (e) {
      return taux;
    }
  }

  static String getLibelleResultat(String niveau) {
    switch (niveau.toLowerCase()) {
      case 'niveau_i':
        return 'Résultat global CEPE par CISCO : ';
      case 'niveau_ii':
        return 'Résultat global BEPC par CISCO : ';
      case 'niveau_iii':
        return 'Résultat global BAC par CISCO : ';
      default:
        return 'Résultat global par CISCO : ';
    }
  }
}
