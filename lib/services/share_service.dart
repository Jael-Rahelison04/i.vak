// services/share_service.dart
import 'package:share_plus/share_plus.dart';
import '../model/etablissement.dart';

class ShareService {
  static Future<void> shareSchoolInfo({
    required Etablissement etablissement,
    required Function(String) showSnackBar,
  }) async {
    try {
      final shareText = _buildShareText(etablissement);
      await Share.share(
        shareText,
        subject: 'Information sur ${etablissement.nom_etab}',
      );
    } catch (e) {
      showSnackBar('Erreur lors du partage: $e');
    }
  }

  static String _buildShareText(Etablissement etablissement) {
    final buffer = StringBuffer();

    // En-tête principal
    buffer.writeln('🏫 ${etablissement.nom_etab}');
    buffer.writeln('📍 ${etablissement.adresse_etablissement}');
    buffer.writeln('');

    // Informations générales
    buffer.writeln('📊 INFORMATIONS GÉNÉRALES:');
    buffer.writeln('• Secteur: ${etablissement.secteur}');
    buffer.writeln('• Niveau: ${_formatNiveau(etablissement.niveau)}');
    buffer.writeln('• CISCO: ${etablissement.cisco}');
    buffer.writeln('• Commune: ${etablissement.commune}');
    buffer.writeln('• Fokontany: ${etablissement.fokontany}');

    // Résultat global
    if (etablissement.niveau.toLowerCase() != 'prescolaire' &&
        etablissement.resultat.isNotEmpty &&
        etablissement.resultat.toLowerCase() != 'indisponible') {
      String libelleResultat;
      switch (etablissement.niveau.toLowerCase()) {
        case 'niveau_i':
          libelleResultat = 'Résultat global CEPE par CISCO';
          break;
        case 'niveau_ii':
          libelleResultat = 'Résultat global BEPC par CISCO';
          break;
        case 'niveau_iii':
          libelleResultat = 'Résultat global BAC par CISCO';
          break;
        default:
          libelleResultat = 'Résultat global par CISCO';
      }

      String formattedResult;
      try {
        double value = double.parse(etablissement.resultat);
        formattedResult = "${(value * 100).toStringAsFixed(2)} %";
      } catch (e) {
        formattedResult = etablissement.resultat;
      }

      buffer.writeln('• $libelleResultat: $formattedResult');
    }
    buffer.writeln('');

    // QUALITÉ DU PERSONNEL
    buffer.writeln('👥 QUALITÉ DU PERSONNEL:');
    if (etablissement.nombre_enseignant_non_fonctionnaire.isNotEmpty &&
        etablissement.nombre_enseignant_non_fonctionnaire != "0") {
      buffer.writeln(
        '• Enseignants non-fonctionnaires: ${etablissement.nombre_enseignant_non_fonctionnaire}',
      );
    }
    if (etablissement.nombre_enseignant_fonctionnaire.isNotEmpty &&
        etablissement.nombre_enseignant_fonctionnaire != "0") {
      buffer.writeln(
        '• Enseignants fonctionnaires: ${etablissement.nombre_enseignant_fonctionnaire}',
      );
    }
    if (etablissement
            .nombre_personel_administratif_non_fonctionnaire
            .isNotEmpty &&
        etablissement.nombre_personel_administratif_non_fonctionnaire != "0") {
      buffer.writeln(
        '• Personnel administratif non-fonctionnaires: ${etablissement.nombre_personel_administratif_non_fonctionnaire}',
      );
    }
    if (etablissement.nombre_personel_administratif_fonctionnaire.isNotEmpty &&
        etablissement.nombre_personel_administratif_fonctionnaire != "0") {
      buffer.writeln(
        '• Personnel administratif fonctionnaires: ${etablissement.nombre_personel_administratif_fonctionnaire}',
      );
    }
    if (etablissement.nombre_benevoles.isNotEmpty &&
        etablissement.nombre_benevoles != "0") {
      buffer.writeln('• Bénévoles: ${etablissement.nombre_benevoles}');
    }
    if (etablissement.effectif_total_personnel.isNotEmpty &&
        etablissement.effectif_total_personnel != "0") {
      buffer.writeln(
        '• EFFECTIF TOTAL: ${etablissement.effectif_total_personnel}',
      );
    }
    buffer.writeln('');

    // STATISTIQUES DES DIPLÔMES DES ENSEIGNANTS
    buffer.writeln('🎓 STATISTIQUES DES DIPLÔMES DES ENSEIGNANTS:');
    _addDiplomeInfo(buffer, 'Diplômes LAPEN', etablissement.diplome_LAPEN);
    _addDiplomeInfo(buffer, 'Diplômes MAPEN', etablissement.diplome_MAPEN);
    _addDiplomeInfo(buffer, 'Diplômes BAC', etablissement.diplome_BAC);
    _addDiplomeInfo(buffer, 'Diplômes BTS', etablissement.diplome_BTS);
    _addDiplomeInfo(buffer, 'Diplômes M1', etablissement.diplome_M1);
    _addDiplomeInfo(buffer, 'Diplômes M2', etablissement.diplome_M2);
    _addDiplomeInfo(
      buffer,
      'Diplômes INGENIEUR',
      etablissement.diplome_INGENIEUR,
    );
    _addDiplomeInfo(buffer, 'Diplômes DEA', etablissement.diplome_DEA);
    _addDiplomeInfo(
      buffer,
      'Diplômes DOCTORAT',
      etablissement.diplome_DOCTORAT,
    );
    _addDiplomeInfo(
      buffer,
      'Diplômes Inférieur BACC',
      etablissement.diplome_Inferieur_BACC,
    );
    buffer.writeln('');

    // NOMBRE DE SECTIONS PAR CLASSE
    buffer.writeln('🏫 NOMBRE DE SECTIONS PAR CLASSE:');

    // NIVEAU PRÉSCOLAIRE
    if (etablissement.niveau.toLowerCase() == 'prescolaire') {
      _addClassInfo(
        buffer,
        'Petite section',
        etablissement.nombre_classe_petite_section,
      );
      _addClassInfo(
        buffer,
        'Moyenne section',
        etablissement.nombre_classe_moyenne_section,
      );
      _addClassInfo(
        buffer,
        'Grande section',
        etablissement.nombre_classe_grande_section,
      );
    }
    // NIVEAU I (12ème à 7ème)
    else if (etablissement.niveau.toLowerCase() == 'niveau_i') {
      _addClassInfo(buffer, '12ème', etablissement.nombre_classe_12em);
      _addClassInfo(buffer, '11ème', etablissement.nombre_classe_11em);
      _addClassInfo(buffer, '10ème', etablissement.nombre_classe_10em);
      _addClassInfo(buffer, '9ème', etablissement.nombre_classe_9em);
      _addClassInfo(buffer, '8ème', etablissement.nombre_classe_8em);
      _addClassInfo(buffer, '7ème', etablissement.nombre_classe_7em);
    }
    // NIVEAU II (6ème à 3ème)
    else if (etablissement.niveau.toLowerCase() == 'niveau_ii') {
      _addClassInfo(buffer, '6ème', etablissement.nombre_classe_6em);
      _addClassInfo(buffer, '5ème', etablissement.nombre_classe_5em);
      _addClassInfo(buffer, '4ème', etablissement.nombre_classe_4em);
      _addClassInfo(buffer, '3ème', etablissement.nombre_classe_3em);
    }
    // NIVEAU III (Seconde, Premières, Terminales)
    else if (etablissement.niveau.toLowerCase() == 'niveau_iii') {
      _addClassInfo(buffer, 'Seconde', etablissement.nombre_classe_seconde);

      // Premières
      _addClassInfo(
        buffer,
        'Première A',
        etablissement.nombre_classe_premiere_A,
      );
      _addClassInfo(
        buffer,
        'Première C',
        etablissement.nombre_classe_premiere_C,
      );
      _addClassInfo(
        buffer,
        'Première D',
        etablissement.nombre_classe_premiere_D,
      );
      _addClassInfo(
        buffer,
        'Première L',
        etablissement.nombre_classe_premiere_L,
      );
      _addClassInfo(
        buffer,
        'Première OSE',
        etablissement.nombre_classe_premiere_Ose,
      );
      _addClassInfo(
        buffer,
        'Première S',
        etablissement.nombre_classe_premiere_S,
      );

      if (etablissement.nombre_classe_premiere_total.isNotEmpty &&
          etablissement.nombre_classe_premiere_total != "0") {
        buffer.writeln(
          '• TOTAL PREMIÈRES: ${etablissement.nombre_classe_premiere_total}',
        );
      }

      // Terminales
      _addClassInfo(
        buffer,
        'Terminale A',
        etablissement.nombre_classe_terminale_A,
      );
      _addClassInfo(
        buffer,
        'Terminale C',
        etablissement.nombre_classe_terminale_C,
      );
      _addClassInfo(
        buffer,
        'Terminale D',
        etablissement.nombre_classe_terminale_D,
      );
      _addClassInfo(
        buffer,
        'Terminale L',
        etablissement.nombre_classe_terminale_L,
      );
      _addClassInfo(
        buffer,
        'Terminale OSE',
        etablissement.nombre_classe_terminale_Ose,
      );
      _addClassInfo(
        buffer,
        'Terminale S',
        etablissement.nombre_classe_terminale_S,
      );

      if (etablissement.nombre_classe_terminale_total.isNotEmpty &&
          etablissement.nombre_classe_terminale_total != "0") {
        buffer.writeln(
          '• TOTAL TERMINALES: ${etablissement.nombre_classe_terminale_total}',
        );
      }
    }
    buffer.writeln('');

    // TAUX DE RÉSULTATS DE BAC (uniquement pour niveau_iii)
    if (etablissement.niveau.toLowerCase() == 'niveau_iii') {
      if ((etablissement.taux_bacc_A1.isNotEmpty &&
              etablissement.taux_bacc_A1 != "0") ||
          (etablissement.taux_bacc_A2.isNotEmpty &&
              etablissement.taux_bacc_A2 != "0") ||
          (etablissement.taux_bacc_C.isNotEmpty &&
              etablissement.taux_bacc_C != "0") ||
          (etablissement.taux_bacc_D.isNotEmpty &&
              etablissement.taux_bacc_D != "0") ||
          (etablissement.taux_bacc_L.isNotEmpty &&
              etablissement.taux_bacc_L != "0") ||
          (etablissement.taux_bacc_Ose.isNotEmpty &&
              etablissement.taux_bacc_Ose != "0") ||
          (etablissement.taux_bacc_S.isNotEmpty &&
              etablissement.taux_bacc_S != "0")) {
        buffer.writeln('📈 TAUX DE RÉSULTATS DE BAC:');

        _addTauxBacInfo(buffer, 'BAC Série A1', etablissement.taux_bacc_A1);
        _addTauxBacInfo(buffer, 'BAC Série A2', etablissement.taux_bacc_A2);
        _addTauxBacInfo(buffer, 'BAC Série C', etablissement.taux_bacc_C);
        _addTauxBacInfo(buffer, 'BAC Série D', etablissement.taux_bacc_D);
        _addTauxBacInfo(buffer, 'BAC Série L', etablissement.taux_bacc_L);
        _addTauxBacInfo(buffer, 'BAC Série OSE', etablissement.taux_bacc_Ose);
        _addTauxBacInfo(buffer, 'BAC Série S', etablissement.taux_bacc_S);

        buffer.writeln('');
      }
    }

    // PLUS D'INFORMATIONS ET CONTACT
    buffer.writeln('📞 PLUS D\'INFORMATIONS ET CONTACT:');
    buffer.writeln('• Adresse: ${etablissement.adresse_etablissement}');
    if (etablissement.nom_prenom_directeur.isNotEmpty) {
      buffer.writeln('• Directeur: ${etablissement.nom_prenom_directeur}');
    }
    if (etablissement.contact_directeur.isNotEmpty) {
      buffer.writeln('• Téléphone: ${etablissement.contact_directeur}');
    }

    buffer.writeln('');
    buffer.writeln('📱 Partagé via l\'application i.Vak');

    return buffer.toString();
  }

  static void _addDiplomeInfo(StringBuffer buffer, String title, String value) {
    if (value.isNotEmpty && value != "0") {
      buffer.writeln('• $title: $value');
    }
  }

  static void _addClassInfo(StringBuffer buffer, String level, String count) {
    if (count.isNotEmpty && count != "0") {
      buffer.writeln('• $level: $count classe(s)');
    }
  }

  static void _addTauxBacInfo(StringBuffer buffer, String serie, String taux) {
    if (taux.isNotEmpty && taux != "0") {
      String formattedTaux;
      try {
        double value = double.parse(taux);
        formattedTaux = "${(value * 100).toStringAsFixed(2)} %";
      } catch (e) {
        formattedTaux = taux;
      }
      buffer.writeln('• $serie: $formattedTaux');
    }
  }

  static String _formatNiveau(String niveau) {
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
}
