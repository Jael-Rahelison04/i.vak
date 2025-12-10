class Etablissement {
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

  Etablissement({
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

  Map<String, dynamic> toJson() {
    return {
      'secteur': secteur,
      'niveau': niveau,
      'cisco': cisco,
      'commune': commune,
      'fokontany': fokontany,
      'nom_etab': nom_etab,
      'x': x,
      'y': y,
      'resultat': resultat,
      'nombre_enseignant_non_fonctionnaire':
          nombre_enseignant_non_fonctionnaire,
      'nombre_enseignant_fonctionnaire': nombre_enseignant_fonctionnaire,
      'nombre_personel_administratif_non_fonctionnaire':
          nombre_personel_administratif_non_fonctionnaire,
      'nombre_personel_administratif_fonctionnaire':
          nombre_personel_administratif_fonctionnaire,
      'nombre_benevoles': nombre_benevoles,
      'effectif_total_personnel': effectif_total_personnel,
      'diplome_LAPEN': diplome_LAPEN,
      'diplome_MAPEN': diplome_MAPEN,
      'diplome_BAC': diplome_BAC,
      'diplome_BTS': diplome_BTS,
      'diplome_M1': diplome_M1,
      'diplome_M2': diplome_M2,
      'diplome_INGENIEUR': diplome_INGENIEUR,
      'diplome_DEA': diplome_DEA,
      'diplome_DOCTORAT': diplome_DOCTORAT,
      'diplome_Inferieur_BACC': diplome_Inferieur_BACC,
      'nom_prenom_directeur': nom_prenom_directeur,
      'contact_directeur': contact_directeur,
      'adresse_etablissement': adresse_etablissement,
      'nombre_classe_petite_section': nombre_classe_petite_section,
      'nombre_classe_moyenne_section': nombre_classe_moyenne_section,
      'nombre_classe_grande_section': nombre_classe_grande_section,
      'nombre_classe_12em': nombre_classe_12em,
      'nombre_classe_11em': nombre_classe_11em,
      'nombre_classe_10em': nombre_classe_10em,
      'nombre_classe_9em': nombre_classe_9em,
      'nombre_classe_8em': nombre_classe_8em,
      'nombre_classe_7em': nombre_classe_7em,
      'nombre_classe_6em': nombre_classe_6em,
      'nombre_classe_5em': nombre_classe_5em,
      'nombre_classe_4em': nombre_classe_4em,
      'nombre_classe_3em': nombre_classe_3em,
      'nombre_classe_seconde': nombre_classe_seconde,
      'nombre_classe_premiere_A': nombre_classe_premiere_A,
      'nombre_classe_premiere_C': nombre_classe_premiere_C,
      'nombre_classe_premiere_D': nombre_classe_premiere_D,
      'nombre_classe_premiere_L': nombre_classe_premiere_L,
      'nombre_classe_premiere_Ose': nombre_classe_premiere_Ose,
      'nombre_classe_premiere_S': nombre_classe_premiere_S,
      'nombre_classe_premiere_total': nombre_classe_premiere_total,
      'nombre_classe_terminale_A': nombre_classe_terminale_A,
      'nombre_classe_terminale_C': nombre_classe_terminale_C,
      'nombre_classe_terminale_D': nombre_classe_terminale_D,
      'nombre_classe_terminale_L': nombre_classe_terminale_L,
      'nombre_classe_terminale_S': nombre_classe_terminale_S,
      'nombre_classe_terminale_Ose': nombre_classe_terminale_Ose,
      'nombre_classe_terminale_total': nombre_classe_terminale_total,
      'taux_bacc_A1': taux_bacc_A1,
      'taux_bacc_A2': taux_bacc_A2,
      'taux_bacc_C': taux_bacc_C,
      'taux_bacc_D': taux_bacc_D,
      'taux_bacc_L': taux_bacc_L,
      'taux_bacc_Ose': taux_bacc_Ose,
      'taux_bacc_S': taux_bacc_S,
    };
  }

  factory Etablissement.fromJson(Map<String, dynamic> json) {
    double parseToDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    String str(dynamic v) => v?.toString() ?? '';

    return Etablissement(
      secteur: str(json['secteur']),
      niveau: str(json['niveau']),
      cisco: str(json['cisco']),
      commune: str(json['commune']),
      fokontany: str(json['fokontany']),
      nom_etab: str(json['nom_etab']),
      x: parseToDouble(json['x']),
      y: parseToDouble(json['y']),
      resultat: str(json['resultat']),
      nombre_enseignant_non_fonctionnaire: str(
        json['nombre_enseignant_non_fonctionnaire'],
      ),
      nombre_enseignant_fonctionnaire: str(
        json['nombre_enseignant_fonctionnaire'],
      ),
      nombre_personel_administratif_non_fonctionnaire: str(
        json['nombre_personel_administratif_non_fonctionnaire'],
      ),
      nombre_personel_administratif_fonctionnaire: str(
        json['nombre_personel_administratif_fonctionnaire'],
      ),
      nombre_benevoles: str(json['nombre_benevoles']),
      effectif_total_personnel: str(json['effectif_total_personnel']),
      diplome_LAPEN: str(json['diplome_LAPEN']),
      diplome_MAPEN: str(json['diplome_MAPEN']),
      diplome_BAC: str(json['diplome_BAC']),
      diplome_BTS: str(json['diplome_BTS']),
      diplome_M1: str(json['diplome_M1']),
      diplome_M2: str(json['diplome_M2']),
      diplome_INGENIEUR: str(json['diplome_INGENIEUR']),
      diplome_DEA: str(json['diplome_DEA']),
      diplome_DOCTORAT: str(json['diplome_DOCTORAT']),
      diplome_Inferieur_BACC: str(json['diplome_Inferieur_BACC']),
      nom_prenom_directeur: str(json['nom_prenom_directeur']),
      contact_directeur: str(json['contact_directeur']),
      adresse_etablissement: str(json['adresse_etablissement']),
      nombre_classe_petite_section: str(json['nombre_classe_petite_section']),
      nombre_classe_moyenne_section: str(json['nombre_classe_moyenne_section']),
      nombre_classe_grande_section: str(json['nombre_classe_grande_section']),
      nombre_classe_12em: str(json['nombre_classe_12em']),
      nombre_classe_11em: str(json['nombre_classe_11em']),
      nombre_classe_10em: str(json['nombre_classe_10em']),
      nombre_classe_9em: str(json['nombre_classe_9em']),
      nombre_classe_8em: str(json['nombre_classe_8em']),
      nombre_classe_7em: str(json['nombre_classe_7em']),
      nombre_classe_6em: str(json['nombre_classe_6em']),
      nombre_classe_5em: str(json['nombre_classe_5em']),
      nombre_classe_4em: str(json['nombre_classe_4em']),
      nombre_classe_3em: str(json['nombre_classe_3em']),
      nombre_classe_seconde: str(json['nombre_classe_seconde']),
      nombre_classe_premiere_A: str(json['nombre_classe_premiere_A']),
      nombre_classe_premiere_C: str(json['nombre_classe_premiere_C']),
      nombre_classe_premiere_D: str(json['nombre_classe_premiere_D']),
      nombre_classe_premiere_L: str(json['nombre_classe_premiere_L']),
      nombre_classe_premiere_Ose: str(json['nombre_classe_premiere_Ose']),
      nombre_classe_premiere_S: str(json['nombre_classe_premiere_S']),
      nombre_classe_premiere_total: str(json['nombre_classe_premiere_total']),
      nombre_classe_terminale_A: str(json['nombre_classe_terminale_A']),
      nombre_classe_terminale_C: str(json['nombre_classe_terminale_C']),
      nombre_classe_terminale_D: str(json['nombre_classe_terminale_D']),
      nombre_classe_terminale_L: str(json['nombre_classe_terminale_L']),
      nombre_classe_terminale_S: str(json['nombre_classe_terminale_S']),
      nombre_classe_terminale_Ose: str(json['nombre_classe_terminale_Ose']),
      nombre_classe_terminale_total: str(json['nombre_classe_terminale_total']),
      taux_bacc_A1: str(json['taux_bacc_A1']),
      taux_bacc_A2: str(json['taux_bacc_A2']),
      taux_bacc_C: str(json['taux_bacc_C']),
      taux_bacc_D: str(json['taux_bacc_D']),
      taux_bacc_L: str(json['taux_bacc_L']),
      taux_bacc_Ose: str(json['taux_bacc_Ose']),
      taux_bacc_S: str(json['taux_bacc_S']),
    );
  }
}
