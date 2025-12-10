import 'package:annuaire_scolaire/pages/school_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:annuaire_scolaire/services/etablissement_service.dart';
import '../model/etablissement.dart';

class EtablissementManager {
  final Function(Etablissement) onEtablissementSelected;
  final Function(List<Etablissement>) onEtablissementsUpdated;
  final Function(Etablissement) onStartNavigation;
  final BuildContext parentContext;

  List<Etablissement> _etablissements = [];
  Etablissement? _selectedEtablissement;
  List<Marker> _cachedSchoolMarkers = [];
  static const LatLng _defaultLocation = LatLng(-18.8792, 47.5079);

  EtablissementManager({
    required this.onEtablissementSelected,
    required this.onEtablissementsUpdated,
    required this.onStartNavigation,
    required this.parentContext,
  });

  Future<void> loadEtablissements() async {
    try {
      final list = await EtablissementService.loadEtablissements();
      _etablissements = list;
      onEtablissementsUpdated(_etablissements);
      debugPrint(
        '[EtablissementManager] Loaded ${_etablissements.length} établissements (depuis cache)',
      );
    } catch (e) {
      debugPrint('[EtablissementManager] Erreur cache: $e');
      throw Exception('Données indisponibles hors ligne');
    }
  }

  void updateEtablissements(List<Etablissement> newList) {
    _etablissements = newList;
    onEtablissementsUpdated(_etablissements);
    _cachedSchoolMarkers.clear(); // Invalider le cache
    debugPrint(
      '[EtablissementManager] Etablissements mis à jour via refresh : ${_etablissements.length}',
    );
  }

  List<Marker> getSchoolMarkers(LatLng userPosition) {
    if (_cachedSchoolMarkers.isNotEmpty) {
      final lastPos = _cachedSchoolMarkers.first.point;
      final dist = Distance().distance(lastPos, userPosition);
      if (dist < 50) return _cachedSchoolMarkers;
    }

    _cachedSchoolMarkers = EtablissementService.getSchoolMarkers(
      _etablissements,
      userPosition,
      (etab) {
        _selectedEtablissement = etab;
        onEtablissementSelected(etab);
        showEtablissementBottomSheet(etab, userPosition);
      },
    );

    return _cachedSchoolMarkers;
  }

  void showEtablissementBottomSheet(Etablissement etab, LatLng userPosition) {
    _selectedEtablissement = etab;

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildSchoolBottomSheet(etab, userPosition),
    );
  }

  Widget _buildSchoolBottomSheet(Etablissement etab, LatLng userPosition) {
    return SchoolBottomSheet(
      etablissement: etab,
      onClose: closeBottomSheet,
      userPosition: userPosition,
      onStartNavigation: onStartNavigation,
      parentContext: parentContext,
    );
  }

  void closeBottomSheet() {
    _selectedEtablissement = null;
  }

  void setCurrentPosition(LatLng position) {}

  // Getters pour accéder à l'état
  List<Etablissement> get etablissements => _etablissements;
  Etablissement? get selectedEtablissement => _selectedEtablissement;
  LatLng get defaultLocation => _defaultLocation;

  void dispose() {
    _cachedSchoolMarkers.clear();
    _selectedEtablissement = null;
  }
}
