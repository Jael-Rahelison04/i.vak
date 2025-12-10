import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:annuaire_scolaire/services/navigation_service.dart';
import 'package:annuaire_scolaire/services/dialog_service.dart';
import '../model/etablissement.dart';

class NavigationManager {
  final BuildContext context;
  final Function(List<LatLng>) onRouteCalculated; // CHANGEMENT ICI
  final Function() onNavigationStopped;
  final Function() onMapMoveToCurrentPosition;
  final double initialZoom;

  List<LatLng> _polylinePoints = [];
  bool _isNavigating = false;
  Etablissement? _navigationDestination;
  Timer? _navigationUpdateTimer;
  LatLng? _currentPosition;
  bool _mapIsReady = false;

  NavigationManager({
    required this.context,
    required this.onRouteCalculated,
    required this.onNavigationStopped,
    required this.onMapMoveToCurrentPosition,
    required this.initialZoom,
  });

  Future<void> calculateRoute(LatLng destination) async {
    if (_currentPosition == null) return;

    final points = await NavigationService.calculateRoute(
      _currentPosition!,
      destination,
    );

    _polylinePoints = points;
    onRouteCalculated(points); // CORRECTION ICI

    if (points.length <= 2) {
      DialogService.showSnackBar(
        context,
        'Itinéraire approximatif (service temporairement indisponible)',
      );
    }
  }

  void startNavigation(Etablissement destination) {
    _isNavigating = true;
    _navigationDestination = destination;

    calculateRoute(LatLng(destination.y, destination.x));
    _startNavigationTracking();
  }

  void stopNavigation() {
    debugPrint(
      '[NavigationManager] Début stopNavigation - _isNavigating: $_isNavigating',
    );

    _navigationUpdateTimer?.cancel();
    _navigationUpdateTimer = null;

    _isNavigating = false;
    _navigationDestination = null;

    _polylinePoints = [];
    onRouteCalculated(_polylinePoints); // CORRECTION ICI

    debugPrint(
      '[NavigationManager] Navigation arrêtée - itinéraire effacé, points: ${_polylinePoints.length}',
    );

    if (_mapIsReady && _currentPosition != null) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!_isNavigating) {
          onMapMoveToCurrentPosition();
        }
      });
    }

    onNavigationStopped();
  }

  void _startNavigationTracking() {
    _navigationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) {
      if (!_isNavigating || _navigationDestination == null) {
        timer.cancel();
        return;
      }

      calculateRoute(
        LatLng(_navigationDestination!.y, _navigationDestination!.x),
      );
      _checkRouteDeviation();
    });
  }

  void _checkRouteDeviation() {
    if (_currentPosition == null || _polylinePoints.length < 2) return;

    if (_navigationDestination != null) {
      final destination = LatLng(
        _navigationDestination!.y,
        _navigationDestination!.x,
      );
      final distanceToDestination = Distance().distance(
        _currentPosition!,
        destination,
      );

      if (distanceToDestination <= 20) {
        debugPrint(
          '[NavigationManager] Arrivée à destination - distance: ${distanceToDestination.toStringAsFixed(1)}m',
        );
        DialogService.showArrivalNotification(context);
        stopNavigation();
        return;
      }
    }

    final shouldRecalculate = NavigationService.checkRouteDeviation(
      _currentPosition!,
      _polylinePoints,
      _navigationDestination!,
    );

    if (shouldRecalculate) {
      debugPrint(
        '[NavigationManager] Déviation détectée, recalcul itinéraire...',
      );
      calculateRoute(
        LatLng(_navigationDestination!.y, _navigationDestination!.x),
      );
    }
  }

  List<Marker> getRouteMarkers() {
    return <Marker>[];
  }

  Widget buildNavigationHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.navigation, color: Colors.blue[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Navigation vers',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  _navigationDestination?.nom_etab ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 24),
              onPressed: stopNavigation,
            ),
          ),
        ],
      ),
    );
  }

  // Setters pour mettre à jour l'état externe
  void setCurrentPosition(LatLng position) {
    _currentPosition = position;
  }

  void setMapReady(bool ready) {
    _mapIsReady = ready;
  }

  // Getters pour accéder à l'état
  bool get isNavigating => _isNavigating;
  List<LatLng> get polylinePoints => _polylinePoints;
  Etablissement? get navigationDestination => _navigationDestination;

  void dispose() {
    _navigationUpdateTimer?.cancel();
    _navigationUpdateTimer = null;
  }
}
