// lib/utils/excel_parser.dart
import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../model/etablissement.dart';

/// --- Fonctions utilitaires pour éviter les répétitions ---
String cellToString(Data? cell) {
  return cell?.value?.toString() ?? '';
}

double cellToDouble(Data? cell) {
  if (cell?.value is double) return cell!.value as double;
  return double.tryParse(cell?.value?.toString() ?? '0') ?? 0.0;
}

/// Parser principal
List<Etablissement> parseExcelInIsolate(Uint8List bytes) {
  var excel = Excel.decodeBytes(bytes);
  List<Etablissement> etablissements = [];

  final sheetsToRead = ['prescolaire', 'niveau_I', 'niveau_II', 'niveau_III'];
  final Map<String, int> resultatColumnIndexes = {
    'niveau_I': 10,
    'niveau_II': 11,
    'niveau_III': 12,
  };

  for (var sheetName in sheetsToRead) {
    var sheet = excel.tables[sheetName];
    if (sheet == null) continue;

    int resultatIndex = resultatColumnIndexes[sheetName] ?? 7;

    for (var row in sheet.rows.skip(1)) {
      final cisco = cellToString(row[2]);
      final secteur = cellToString(row[1]);
      final nomEtab = cellToString(row[6]);

      // Résultat spécifique
      String resultat = '';
      if (sheetName != 'prescolaire' && row.length > resultatIndex) {
        resultat = cellToString(row[resultatIndex]);
      }

      final niveau = sheetName;

      etablissements.add(
        Etablissement(
          nom_etab: nomEtab,
          secteur: secteur,
          niveau: niveau,
          cisco: cisco,
          commune: cellToString(row[3]),
          fokontany: cellToString(row[5]),
          x: row.length > 7 ? cellToDouble(row[7]) : 0.0,
          y: row.length > 8 ? cellToDouble(row[8]) : 0.0,
          resultat: resultat,
          nombre_enseignant_non_fonctionnaire: cellToString(row[10]),
          nombre_enseignant_fonctionnaire: cellToString(row[11]),
          nombre_personel_administratif_non_fonctionnaire: cellToString(
            row[12],
          ),
          nombre_personel_administratif_fonctionnaire: cellToString(row[13]),
          nombre_benevoles: cellToString(row[14]),
          effectif_total_personnel: cellToString(row[15]),
          diplome_LAPEN: cellToString(row[16]),
          diplome_MAPEN: cellToString(row[17]),
          diplome_BAC: cellToString(row[18]),
          diplome_BTS: cellToString(row[19]),
          diplome_M1: cellToString(row[20]),
          diplome_M2: cellToString(row[21]),
          diplome_INGENIEUR: cellToString(row[22]),
          diplome_DEA: cellToString(row[23]),
          diplome_DOCTORAT: cellToString(row[24]),
          diplome_Inferieur_BACC: cellToString(row[25]),
          nom_prenom_directeur: cellToString(row[26]),
          contact_directeur: cellToString(row[27]),
          adresse_etablissement: cellToString(row[28]),
          nombre_classe_petite_section: cellToString(row[29]),
          nombre_classe_moyenne_section: cellToString(row[30]),
          nombre_classe_grande_section: cellToString(row[31]),
          nombre_classe_12em: cellToString(row[32]),
          nombre_classe_11em: cellToString(row[33]),
          nombre_classe_10em: cellToString(row[34]),
          nombre_classe_9em: cellToString(row[35]),
          nombre_classe_8em: cellToString(row[36]),
          nombre_classe_7em: cellToString(row[37]),
          nombre_classe_6em: cellToString(row[38]),
          nombre_classe_5em: cellToString(row[39]),
          nombre_classe_4em: cellToString(row[40]),
          nombre_classe_3em: cellToString(row[41]),
          nombre_classe_seconde: cellToString(row[42]),
          nombre_classe_premiere_A: cellToString(row[43]),
          nombre_classe_premiere_C: cellToString(row[44]),
          nombre_classe_premiere_D: cellToString(row[45]),
          nombre_classe_premiere_L: cellToString(row[46]),
          nombre_classe_premiere_Ose: cellToString(row[47]),
          nombre_classe_premiere_S: cellToString(row[48]),
          nombre_classe_premiere_total: cellToString(row[49]),
          nombre_classe_terminale_A: cellToString(row[50]),
          nombre_classe_terminale_C: cellToString(row[51]),
          nombre_classe_terminale_D: cellToString(row[52]),
          nombre_classe_terminale_L: cellToString(row[53]),
          nombre_classe_terminale_S: cellToString(row[54]),
          nombre_classe_terminale_Ose: cellToString(row[55]),
          nombre_classe_terminale_total: cellToString(row[56]),
          taux_bacc_A1: cellToString(row[57]),
          taux_bacc_A2: cellToString(row[58]),
          taux_bacc_C: cellToString(row[59]),
          taux_bacc_D: cellToString(row[60]),
          taux_bacc_L: cellToString(row[61]),
          taux_bacc_Ose: cellToString(row[62]),
          taux_bacc_S: cellToString(row[63]),
        ),
      );
    }
  }
  return etablissements;
}
