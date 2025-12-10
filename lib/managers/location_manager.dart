import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:annuaire_scolaire/services/location_service.dart';
import 'package:annuaire_scolaire/services/connectivity_service.dart';
import 'package:annuaire_scolaire/services/dialog_service.dart';

class LocationManager {
  final BuildContext context;
  final Function(LatLng) onPositionUpdated;
  final Function(bool) onLoadingStateChanged;
  final LocationAccuracy locationAccuracy;
  final double initialZoom;

  bool _hasStartedLocation = false;
  bool _isListening = false;
  LatLng? _currentPosition;
  bool _isLoading = true;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _debounceTimer;
  static const LatLng _defaultLocation = LatLng(-18.8792, 47.5079);

  LocationManager({
    required this.context,
    required this.onPositionUpdated,
    required this.onLoadingStateChanged,
    required this.locationAccuracy,
    required this.initialZoom,
  });

  Future<void> stopListeningLocation() async {
    if (!_isListening) return;
    _isListening = false;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    if (_positionStreamSubscription != null) {
      await _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
    }
    try {
      await Geolocator.getServiceStatusStream().drain();
      await Future.delayed(const Duration(milliseconds: 400));
      debugPrint('[LocationManager] HUAWEI : GPS libéré en 400ms');
    } catch (e) {
      debugPrint('[LocationManager] Erreur drain: $e');
    }
  }

  void setCurrentPosition(LatLng position) {
    _currentPosition = position;
    _isLoading = false;
    onPositionUpdated(position);
    onLoadingStateChanged(false);
    debugPrint(
      '[LocationManager] Position mise à jour manuellement: $position',
    );
  }

  void startListeningLocation() async {
    if (_isListening || _positionStreamSubscription != null) return;
    _isListening = true;
    try {
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: LocationSettings(
              accuracy: locationAccuracy,
              distanceFilter: 5,
            ),
          ).listen(
            (position) {
              final newPos = LatLng(position.latitude, position.longitude);
              _debounceTimer?.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 400), () {
                _currentPosition = newPos;
                _isLoading = false;
                onPositionUpdated(newPos);
                onLoadingStateChanged(false);
                debugPrint(
                  '[LocationManager] Position stream → position mise à jour',
                );
              });
            },
            onError: (e) {
              debugPrint('[LocationManager] Erreur stream GPS: $e');
              DialogService.showSnackBar(context, 'Erreur GPS: $e');
            },
          );
    } catch (e) {
      debugPrint('[LocationManager] Erreur démarrage stream: $e');
    }
  }

  void stopLoading() {
    _isLoading = false;
    onLoadingStateChanged(false);
    debugPrint('[LocationManager] Chargement arrêté');
  }

  Future<void> getUserLocation() async {
    debugPrint('[LocationManager] Vérification de la connectivité...');
    if (!await ConnectivityService.checkNetworkConnectivity()) {
      stopLoading();
      DialogService.showSnackBar(
        context,
        'Aucune connexion réseau. Veuillez vérifier votre connexion.',
        actionLabel: 'Réessayer',
        onAction: checkAndRequestLocationService,
      );
      return;
    }

    debugPrint('[LocationManager] Vérification des permissions...');
    final permissionGranted = await LocationService.handleLocationPermission();

    if (!permissionGranted) {
      stopLoading();
      return;
    }

    debugPrint('[LocationManager] Lancement de la géolocalisation...');

    try {
      debugPrint('[LocationManager] Récupération de la position rapide...');
      final position = await LocationService.getInitialPosition();

      if (position != null) {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
        onPositionUpdated(_currentPosition!);
        onLoadingStateChanged(false);
        debugPrint(
          '[LocationManager] Position initiale trouvée: $_currentPosition',
        );

        startListeningLocation();

        Future.delayed(const Duration(milliseconds: 500), () async {
          final refined = await LocationService.refinePosition();
          if (refined != null) {
            _currentPosition = LatLng(refined.latitude, refined.longitude);
            onPositionUpdated(_currentPosition!);
            debugPrint(
              '[LocationManager] Position précisée: $_currentPosition',
            );
          }
        });
      } else {
        _currentPosition = _defaultLocation;
        _isLoading = false;
        onPositionUpdated(_currentPosition!);
        onLoadingStateChanged(false);
        DialogService.showSnackBar(
          context,
          'Impossible de récupérer votre position GPS, position par défaut utilisée.',
        );
      }
    } catch (e) {
      debugPrint('[LocationManager] Erreur de localisation : $e');
      _currentPosition = _defaultLocation;
      _isLoading = false;
      onPositionUpdated(_currentPosition!);
      onLoadingStateChanged(false);
    }
  }

  Future<void> refreshLocation() async {
    await checkAndRequestLocationService();
  }

  Future<void> checkAndRequestLocationService() async {
    if (!_hasStartedLocation) {
      _hasStartedLocation = true;
    }

    _isLoading = true;
    onLoadingStateChanged(true);

    await getUserLocation();

    if (_currentPosition == null) {
      stopLoading();
    }
  }

  void startLoadingTimeout() {
    Future.delayed(const Duration(seconds: 12), () {
      if (_isLoading) {
        stopLoading();
        DialogService.showSnackBar(
          context,
          'Impossible de récupérer la position GPS dans le délai imparti.',
        );
      }
    });
  }

  void initializeWithDelay(bool isOnline) async {
    if (_currentPosition == null && !_hasStartedLocation && isOnline) {
      _hasStartedLocation = true;
      startLoadingTimeout();
      checkAndRequestLocationService();
    }
  }

  // Setters pour mettre à jour l'état
  void setHasStartedLocation(bool started) {
    _hasStartedLocation = started;
  }

  // Getters pour accéder à l'état
  LatLng? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  bool get hasStartedLocation => _hasStartedLocation;
  bool get isListening => _isListening;

  void dispose() {
    stopListeningLocation();
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}
