import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:annuaire_scolaire/managers/navigation_manager.dart';
import 'package:annuaire_scolaire/managers/location_manager.dart';
import 'package:annuaire_scolaire/managers/etablissement_manager.dart';
import 'package:annuaire_scolaire/services/location_service.dart';
import '../model/etablissement.dart';

void log(String message) {
  debugPrint('[LocalizePage] $message');
}

class LocalizePage extends StatefulWidget {
  final bool initialIsOnline;
  final double initialZoom;
  final LocationAccuracy locationAccuracy;

  const LocalizePage({
    super.key,
    this.initialIsOnline = true,
    this.initialZoom = 15.0,
    this.locationAccuracy = LocationAccuracy.medium,
  });

  @override
  State<LocalizePage> createState() => LocalizePageState();
}

class LocalizePageState extends State<LocalizePage>
    with AutomaticKeepAliveClientMixin {
  static const LatLng _defaultLocation = LatLng(-18.8792, 47.5079);
  static const Color _primaryColor = Color(0xff036B54);

  // --- Managers (Non-nullables car initialisés dans initState) ---
  late NavigationManager _navigationManager;
  late LocationManager _locationManager;
  late EtablissementManager _etablissementManager;

  // --- Contrôleurs et Notifiers ---
  final MapController _mapController = MapController();
  bool _mapIsReady = false;

  // Remplacent les nombreux setState() par une mise à jour ciblée
  final ValueNotifier<bool> _isOnlineNotifier = ValueNotifier(true);
  final ValueNotifier<LatLng?> _currentPositionNotifier = ValueNotifier(null);
  final ValueNotifier<List<LatLng>> _routeNotifier = ValueNotifier([]);
  final ValueNotifier<bool> _isNavigatingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(true);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isOnlineNotifier.value = widget.initialIsOnline;
    _initializeManagers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationManager.initializeWithDelay(_isOnlineNotifier.value);
    });
  }

  void _initializeManagers() {
    // 1. Navigation Manager
    _navigationManager = NavigationManager(
      context: context,
      onRouteCalculated: (points) {
        _routeNotifier.value = points;
        _isNavigatingNotifier.value = true;
      },
      onNavigationStopped: () {
        _routeNotifier.value = [];
        _isNavigatingNotifier.value = false;
      },
      onMapMoveToCurrentPosition: _moveToCurrentPosition,
      initialZoom: widget.initialZoom,
    );

    // 2. Location Manager
    _locationManager = LocationManager(
      context: context,
      onPositionUpdated: (position) {
        _currentPositionNotifier.value =
            position; // Notifie uniquement les marqueurs concernés
        _navigationManager.setCurrentPosition(position);
        _etablissementManager.setCurrentPosition(position);

        // On recentre automatiquement si on est en navigation
        if (_isNavigatingNotifier.value) {
          _moveToCurrentPosition();
        }
      },
      onLoadingStateChanged: (isLoading) {
        _isLoadingNotifier.value = isLoading;
      },
      locationAccuracy: widget.locationAccuracy,
      initialZoom: widget.initialZoom,
    );

    // 3. Etablissement Manager
    _etablissementManager = EtablissementManager(
      onEtablissementSelected: (_) => setState(
        () {},
      ), // Le seul gardé car il impacte la bottom sheet (externe)
      onEtablissementsUpdated: (_) => setState(() {}), // Pareil
      onStartNavigation: (etablissement) {
        _navigationManager.startNavigation(etablissement);
      },
      parentContext: context,
    );

    _etablissementManager.loadEtablissements();
  }

  void _moveToCurrentPosition() {
    final pos = _currentPositionNotifier.value;
    if (pos != null && _mapIsReady) {
      _mapController.move(pos, widget.initialZoom);
    }
  }

  // --- Méthodes publiques (appelées par Home) ---

  void notifyConnectivityChanged(bool isOnline) {
    if (_isOnlineNotifier.value == isOnline) return;

    _isOnlineNotifier.value = isOnline;
    log('Connectivité mise à jour: $isOnline');

    if (isOnline) {
      _locationManager.checkAndRequestLocationService();
    } else {
      _locationManager.stopListeningLocation();
    }
  }

  void updateEtablissements(List<Etablissement> newList) {
    _etablissementManager.updateEtablissements(newList);
  }

  Future<void> refreshLocation() async {
    await _locationManager.refreshLocation();
  }

  // --- Construction de l'UI ---

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildOfflineBanner(),
          _buildNavigationHeader(),
          _buildLoadingIndicator(),
          _buildCopyright(),
          _buildRefineButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentPositionNotifier.value != null && _mapIsReady) {
            _moveToCurrentPosition();
          } else {
            _locationManager.checkAndRequestLocationService();
          }
        },
        backgroundColor: _primaryColor,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _locationManager.currentPosition ?? _defaultLocation,
        initialZoom: widget.initialZoom,
        onMapReady: () {
          _mapIsReady = true;
          _navigationManager.setMapReady(true);
          _moveToCurrentPosition();
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.annuaire_scolaire',
          tileProvider:
              NetworkTileProvider(), // Attention: Voir note en bas sur le offline
        ),

        // Couche Itinéraire (Mise à jour isolée)
        ValueListenableBuilder<List<LatLng>>(
          valueListenable: _routeNotifier,
          builder: (context, route, child) {
            if (route.isEmpty) return const SizedBox.shrink();
            return PolylineLayer(
              polylines: [
                Polyline(
                  points: route,
                  color: Colors.blue.withOpacity(0.7),
                  strokeWidth: 6.0,
                ),
              ],
            );
          },
        ),

        // Couches des marqueurs (Mise à jour isolée sur le changement de position)
        ValueListenableBuilder<LatLng?>(
          valueListenable: _currentPositionNotifier,
          builder: (context, position, child) {
            if (position == null) return const SizedBox.shrink();

            return MarkerLayer(
              markers: [
                // 1. Les écoles (calculées par rapport à la position)
                ..._etablissementManager.getSchoolMarkers(position),
                // 2. La position de l'utilisateur
                _buildUserMarker(position),
              ],
            );
          },
        ),
      ],
    );
  }

  Marker _buildUserMarker(LatLng position) {
    return Marker(
      width: 50.0,
      height: 50.0,
      point: position,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color.fromARGB(255, 36, 25, 236).withOpacity(0.3),
          border: Border.all(
            color: const Color.fromARGB(255, 36, 25, 236),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.navigation,
          color: Color.fromARGB(255, 36, 25, 236),
          size: 25,
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isOnlineNotifier,
      builder: (context, isOnline, child) {
        if (isOnline) return const SizedBox.shrink();
        return Positioned(
          top: 40,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Mode hors-ligne : Carte limitée au cache et navigation désactivée.",
              style: TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationHeader() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isNavigatingNotifier,
      builder: (context, isNavigating, child) {
        if (!isNavigating) return const SizedBox.shrink();
        return Positioned(
          top: 50,
          left: 16,
          right: 16,
          child: _navigationManager.buildNavigationHeader(),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingNotifier,
      builder: (context, isLoading, child) {
        if (!isLoading) return const SizedBox.shrink();
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _primaryColor),
              SizedBox(height: 16),
              Text('Recherche de votre position...'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCopyright() {
    return const Positioned(
      bottom: 8,
      left: 8,
      child: Text(
        '© OpenStreetMap contributors',
        style: TextStyle(fontSize: 12, color: Colors.black),
      ),
    );
  }

  Widget _buildRefineButton() {
    return Positioned(
      right: 16,
      bottom: 80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          fixedSize: const Size(57, 57),
          padding: EdgeInsets.zero,
          elevation: 6,
        ),
        onPressed: () async {
          _isLoadingNotifier.value = true;
          final pos = await LocationService.refinePosition();
          if (pos != null && mounted) {
            _locationManager.setCurrentPosition(
              LatLng(pos.latitude, pos.longitude),
            );
            _moveToCurrentPosition();
          }
          _isLoadingNotifier.value = false;
        },
        child: const Icon(
          Icons.center_focus_strong,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isOnlineNotifier.dispose();
    _currentPositionNotifier.dispose();
    _routeNotifier.dispose();
    _isNavigatingNotifier.dispose();
    _isLoadingNotifier.dispose();

    _navigationManager.dispose();
    _locationManager.stopListeningLocation();
    _etablissementManager.dispose();
    _mapController.dispose();
    super.dispose();
  }
}
