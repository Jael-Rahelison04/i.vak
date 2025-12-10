// services/navigation_service.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/etablissement.dart';

class ItineraryService {
  static bool _alreadyShown = false;

  // === CHOIX DU PROFIL OSRM SELON LE MODE ===
  static String _getOsrmUrl(String mode) {
    switch (mode) {
      case 'driving':
        return 'https://routing.openstreetmap.de/routed-car/route/v1/driving';
      case 'walking':
      case 'transit': // on simule à pied car pas de bus dans OSRM public
        return 'https://routing.openstreetmap.de/routed-foot/route/v1/driving';
      default:
        return 'https://routing.openstreetmap.de/routed-foot/route/v1/driving';
    }
  }

  static String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  static void _showFriendlyError(BuildContext context) {
    // On ne montre le message qu'une seule fois
    if (_alreadyShown) return;
    _alreadyShown = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Trajet exact indisponible pour le moment. "
                "Affichage d'une estimation approximative.",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Calcule la VRAIE distance par les routes (en mètres)
  static Future<double> calculateRealDistance({
    required LatLng userPos,
    required Etablissement etab,
    required BuildContext context,
  }) async {
    final url = Uri.parse(
      '${_getOsrmUrl('driving')}/${userPos.longitude},${userPos.latitude};${etab.x},${etab.y}'
      '?overview=false&alternatives=false&steps=false',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok') {
          return (data['routes'][0]['distance'] as num).toDouble();
        }
      }
    } catch (e) {
      _showFriendlyError(context);
      print('OSRM distance failed: $e');
    }

    // Fallback ligne droite
    final distance = Distance();
    return distance(userPos, LatLng(etab.y, etab.x));
  }

  /// Calcule le temps réel par les routes (voiture, vélo, piéton)
  static Future<String> estimateRealTime({
    required LatLng userPos,
    required Etablissement etab,
    required String mode, // 'driving', 'transit', 'walking'
    required BuildContext context,
  }) async {
    final osrmUrl = _getOsrmUrl(mode);

    final url = Uri.parse(
      '$osrmUrl/${userPos.longitude},${userPos.latitude};${etab.x},${etab.y}'
      '?overview=false&alternatives=false&steps=false',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok') {
          final durationSeconds = (data['routes'][0]['duration'] as num)
              .toDouble();
          final minutes = (durationSeconds / 60).round();
          if (minutes < 1) return 'moins d\'1 min';
          if (minutes < 60) return '$minutes min';
          final hours = minutes ~/ 60;
          final mins = minutes % 60;
          return '$hours h ${mins > 0 ? '$mins min' : ''}';
        }
      }
    } catch (e) {
      print('OSRM time failed ($mode): $e');
    }

    // === FALLBACK estimation manuelle (plus réaliste) ===
    final distanceMeters = await calculateRealDistance(
      userPos: userPos,
      etab: etab,
      context: context,
    );
    double speedKmH = mode == 'driving'
        ? 35
        : mode == 'transit'
        ? 18
        : 5; // à pied
    final timeHours = distanceMeters / 1000 / speedKmH;
    final minutes = (timeHours * 60).toInt();
    if (minutes < 1) return 'moins d\'1 min';
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours h ${mins > 0 ? '$mins min' : ''}';
  }

  static Future<Map<String, String>> loadTripInfo({
    required LatLng userPos,
    required Etablissement etab,
    required BuildContext context,
  }) async {
    _alreadyShown = false;

    final distance = await calculateRealDistance(
      userPos: userPos,
      etab: etab,
      context: context,
    );
    final driving = await estimateRealTime(
      userPos: userPos,
      etab: etab,
      mode: 'driving',
      context: context,
    );
    final transit = await estimateRealTime(
      userPos: userPos,
      etab: etab,
      mode: 'transit',
      context: context,
    );
    final walking = await estimateRealTime(
      userPos: userPos,
      etab: etab,
      mode: 'walking',
      context: context,
    );

    return {
      'distance': _formatDistance(distance),
      'driving': driving,
      'transit': transit,
      'walking': walking,
    };
  }
}
