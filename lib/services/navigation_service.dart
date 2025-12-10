import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:annuaire_scolaire/model/etablissement.dart';

class NavigationService {
  static Future<List<LatLng>> calculateRoute(
    LatLng currentPosition,
    LatLng destination,
  ) async {
    final List<String> osrmUrls = [
      'https://router.project-osrm.org/route/v1/driving/',
      'https://osrm-routing.bullshit.workers.dev/route/v1/driving/',
    ];

    for (final baseUrl in osrmUrls) {
      try {
        final response = await http
            .get(
              Uri.parse(
                '$baseUrl'
                '${currentPosition.longitude},${currentPosition.latitude};'
                '${destination.longitude},${destination.latitude}?'
                'overview=full&geometries=geojson',
              ),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['code'] == 'Ok') {
            final geometry = data['routes'][0]['geometry'];
            final coordinates = geometry['coordinates'] as List;

            return coordinates.map((coord) {
              return LatLng(coord[1].toDouble(), coord[0].toDouble());
            }).toList();
          }
        }
      } catch (e) {
        continue;
      }
    }
    return [currentPosition, destination];
  }

  static double distanceToSegment(
    LatLng point,
    LatLng segmentStart,
    LatLng segmentEnd,
  ) {
    final Distance distance = Distance();

    final A = point.longitude - segmentStart.longitude;
    final B = point.latitude - segmentStart.latitude;
    final C = segmentEnd.longitude - segmentStart.longitude;
    final D = segmentEnd.latitude - segmentStart.latitude;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;
    double param = -1;

    if (lenSq != 0) param = dot / lenSq;

    double xx, yy;

    if (param < 0) {
      xx = segmentStart.longitude;
      yy = segmentStart.latitude;
    } else if (param > 1) {
      xx = segmentEnd.longitude;
      yy = segmentEnd.latitude;
    } else {
      xx = segmentStart.longitude + param * C;
      yy = segmentStart.latitude + param * D;
    }

    return distance(LatLng(point.latitude, point.longitude), LatLng(yy, xx));
  }

  static bool checkRouteDeviation(
    LatLng currentPosition,
    List<LatLng> polylinePoints,
    Etablissement navigationDestination, // Changé de LatLng à Etablissement
  ) {
    if (polylinePoints.length < 2) return false;

    final destination = LatLng(
      navigationDestination
          .y, // Maintenant c'est correct car Etablissement a .y et .x
      navigationDestination.x,
    );
    final distanceToDestination = Distance().distance(
      currentPosition,
      destination,
    );

    if (distanceToDestination <= 20) {
      return true;
    }

    double minDistance = double.infinity;
    for (int i = 0; i < polylinePoints.length - 1; i++) {
      final distance = distanceToSegment(
        currentPosition,
        polylinePoints[i],
        polylinePoints[i + 1],
      );
      minDistance = distance < minDistance ? distance : minDistance;
    }

    return minDistance > 50;
  }
}
