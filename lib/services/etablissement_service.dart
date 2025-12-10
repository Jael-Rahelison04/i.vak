import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:annuaire_scolaire/model/etablissement.dart';
import 'package:annuaire_scolaire/services/data_service.dart';

class EtablissementService {
  static Future<List<Etablissement>> loadEtablissements() async {
    try {
      return await DataService.getEtablissements();
    } catch (e) {
      return [];
    }
  }

  static List<Marker> getSchoolMarkers(
    List<Etablissement> etablissements,
    LatLng currentPosition,
    Function(Etablissement) onTap,
  ) {
    final Distance distanceCalculator = Distance();
    final userPos = currentPosition;

    final filtered = etablissements.where((etab) {
      final etabPos = LatLng(etab.y, etab.x);
      return distanceCalculator(userPos, etabPos) <= 3000;
    }).toList();

    return filtered.map((etab) {
      final color = etab.secteur == 'Privée'
          ? Colors.green
          : Colors.blue.shade500;
      return Marker(
        point: LatLng(etab.y, etab.x),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => onTap(etab),
          child: Icon(Icons.school, color: color, size: 30),
        ),
      );
    }).toList();
  }
}
