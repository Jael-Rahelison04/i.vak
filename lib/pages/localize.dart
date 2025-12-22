import 'dart:async';
import 'package:annuaire_scolaire/managers/navigation_manager.dart';
import 'package:annuaire_scolaire/managers/location_manager.dart';
import 'package:annuaire_scolaire/managers/etablissement_manager.dart';
import 'package:annuaire_scolaire/services/connectivity_service.dart';
import 'package:annuaire_scolaire/services/dialog_service.dart';
import 'package:annuaire_scolaire/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../model/etablissement.dart';

void log(String message) {
  debugPrint('[LocalizePage] $message');
}

class LocalizePage extends StatefulWidget {
  final bool initialIsOnline;
  final double initialZoom;
  final LocationAccuracy locationAccuracy;
  const LocalizePage({
    this.initialIsOnline = true,
    super.key,
    this.initialZoom = 15.0,
    this.locationAccuracy = LocationAccuracy.high,
  });
  @override
  State<LocalizePage> createState() => LocalizePageState();
}

class LocalizePageState extends State<LocalizePage>
    with AutomaticKeepAliveClientMixin {
  // Managers
  NavigationManager? _navigationManager;
  LocationManager? _locationManager;
  EtablissementManager? _etablissementManager;

  // État local simplifié
  late bool _isOnline;
  bool _isCheckingConnection = false;
  bool _mapIsReady = false;
  MapController _mapController = MapController();
  static const LatLng _defaultLocation = LatLng(-18.8792, 47.5079);

  // Getters pour accéder à l'état des managers
  bool get _isNavigating => _navigationManager?.isNavigating ?? false;
  List<LatLng> get _polylinePoints => _navigationManager?.polylinePoints ?? [];
  LatLng? get _currentPosition => _locationManager?.currentPosition;
  bool get _isLoading => _locationManager?.isLoading ?? true;
  List<Etablissement> get _etablissements =>
      _etablissementManager?.etablissements ?? [];
  Etablissement? get _selectedEtablissement =>
      _etablissementManager?.selectedEtablissement;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isOnline = widget.initialIsOnline;
    log('initState: LocalizePage créé');

    _initializeManagers();
    _mapController = MapController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationManager?.initializeWithDelay(_isOnline);
    });

    _locationManager?.checkAndRequestLocationService();
  }

  void _initializeManagers() {
    // Navigation Manager
    _navigationManager = NavigationManager(
      context: context,
      onRouteCalculated: (points) {
        // SUPPRIMER l'assignation - le NavigationManager gère déjà _polylinePoints
        setState(() {}); // Juste notifier le rebuild
      },
      onNavigationStopped: () {
        setState(() {}); // Juste notifier le rebuild
      },
      onMapMoveToCurrentPosition: _moveToCurrentPosition,
      initialZoom: widget.initialZoom,
    );

    // Location Manager
    _locationManager = LocationManager(
      context: context,
      onPositionUpdated: (position) {
        _navigationManager?.setCurrentPosition(position);
        _etablissementManager?.setCurrentPosition(position);
        _moveToCurrentPosition();
        setState(() {});
      },
      onLoadingStateChanged: (isLoading) {
        setState(() {});
      },
      locationAccuracy: widget.locationAccuracy,
      initialZoom: widget.initialZoom,
    );

    // Etablissement Manager
    _etablissementManager = EtablissementManager(
      onEtablissementSelected: (etab) {
        setState(() {});
      },
      onEtablissementsUpdated: (etablissements) {
        setState(() {});
      },
      onStartNavigation: (etablissement) {
        _navigationManager?.startNavigation(etablissement);
        setState(() {});
      },
      parentContext: context,
    );

    // Chargement initial des établissements
    _loadEtablissements();
  }

  Future<void> _loadEtablissements() async {
    try {
      await _etablissementManager?.loadEtablissements();
    } catch (e) {
      log('Erreur cache: $e');
      DialogService.showSnackBar(context, 'Données indisponibles hors ligne');
    }
  }

  void _moveToCurrentPosition() {
    if (_currentPosition != null && _mapIsReady) {
      _mapController.move(_currentPosition!, widget.initialZoom);
    } else {
      debugPrint(
        '[LocalizePage] Pas de position disponible, recentrage ignoré',
      );
    }
  }

  Future<void> checkConnection() async {
    setState(() {
      _isCheckingConnection = true;
    });

    bool online = await ConnectivityService.checkConnection();

    if (!mounted) return;

    setState(() {
      _isOnline = online;
      _isCheckingConnection = false;
    });

    if (_isOnline) {
      await _locationManager?.checkAndRequestLocationService();
    } else {
      await _locationManager?.stopListeningLocation();
    }
  }

  void notifyConnectivityChanged(bool isOnline) {
    if (!mounted) return;
    if (_isOnline == isOnline) return;

    setState(() {
      _isOnline = isOnline;
      log('Connectivité mise à jour dans LocalizePage : $_isOnline');
    });

    if (_isOnline) {
      _locationManager?.checkAndRequestLocationService();
    } else {
      _locationManager?.stopListeningLocation();
    }
  }

  void updateEtablissements(List<Etablissement> newList) {
    _etablissementManager?.updateEtablissements(newList);
  }

  Future<void> refreshLocation() async {
    await _locationManager?.refreshLocation();
  }

  List<Marker> _getSchoolMarkers() {
    if (_currentPosition == null) return [];
    return _etablissementManager?.getSchoolMarkers(_currentPosition!) ?? [];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_isOnline) {
      if (_isCheckingConnection) {
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xff036B54)),
          ),
        );
      } else {
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Aucune connexion internet, veuillez vous connecter s'il vous plaît !",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Lato',
                    color: Color(0xff036B54),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: checkConnection,
                  icon: const Icon(
                    Icons.refresh,
                    color: Color(0xff036B54),
                    size: 30,
                  ),
                  label: const Text(
                    "Actualiser",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      color: Color(0xff036B54),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? _defaultLocation,
              initialZoom: widget.initialZoom,
              onMapReady: () {
                setState(() {
                  _mapIsReady = true;
                  _navigationManager?.setMapReady(true);
                });
                _moveToCurrentPosition();
                log('Carte prête, recentrage sur position');
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.annuaire_scolaire',
                tileProvider: NetworkTileProvider(),
              ),
              if (_polylinePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _polylinePoints,
                      color: Colors.blue.withOpacity(0.7),
                      strokeWidth: 6.0,
                    ),
                  ],
                ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 50.0,
                      height: 50.0,
                      point: _currentPosition!,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(
                            255,
                            36,
                            25,
                            236,
                          ).withOpacity(0.3),
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
                    ),
                  ],
                ),
              if (_etablissements.isNotEmpty && _currentPosition != null)
                MarkerLayer(markers: _getSchoolMarkers()),
            ],
          ),

          if (_isNavigating)
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: _navigationManager!.buildNavigationHeader(),
            ),

          if (_isLoading)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xff036B54)),
                  SizedBox(height: 16),
                  Text('Recherche de votre position...'),
                ],
              ),
            ),

          const Positioned(
            bottom: 8,
            left: 8,
            child: Text(
              '© OpenStreetMap contributors',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 80,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff036B54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                fixedSize: const Size(57, 57),
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                elevation: 6,
              ),
              onPressed: () async {
                setState(() {});
                final pos = await LocationService.refinePosition();
                if (pos != null && mounted) {
                  _locationManager?.setCurrentPosition(
                    LatLng(pos.latitude, pos.longitude),
                  );
                  _moveToCurrentPosition();
                }
                setState(() {});
              },
              child: const Icon(
                Icons.center_focus_strong,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isNavigating
            ? _moveToCurrentPosition
            : () {
                if (_currentPosition != null && _mapIsReady) {
                  _moveToCurrentPosition();
                } else {
                  _locationManager?.checkAndRequestLocationService();
                }
              },
        backgroundColor: const Color(0xff036B54),
        child: const Icon(
          Icons.my_location, // Même icône pour les deux cas
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _navigationManager?.dispose();
    _locationManager?.stopListeningLocation();

    _etablissementManager?.dispose();
    _mapController.dispose();
    super.dispose();
  }
}
