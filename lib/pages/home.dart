import 'dart:async';
import 'package:annuaire_scolaire/services/data_service.dart';
import 'package:annuaire_scolaire/widgets/help_dialog.dart';

import 'package:annuaire_scolaire/widgets/year_selection_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:annuaire_scolaire/pages/search.dart';
import 'package:annuaire_scolaire/pages/localize.dart';
import 'package:annuaire_scolaire/services/connectivity_service.dart';
import 'package:annuaire_scolaire/services/refresh_service.dart';
import 'package:annuaire_scolaire/services/snackbar_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  // ← MÉTHODE PUBLIQUE
  static void handleConnectivityChange(
    BuildContext context,
    List<ConnectivityResult> results,
  ) {
    final homeState = context.findAncestorStateOfType<_HomePageState>();
    homeState?._handleConnectivityChange(results);
  }
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  int _selectedIndex = 0;
  static const List<String> _appBarTitles = <String>['Rechercher', 'Localiser'];

  final GlobalKey<SearchPageState> _searchPageKey =
      GlobalKey<SearchPageState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final GlobalKey<LocalizePageState> _localizeKey =
      GlobalKey<LocalizePageState>();

  bool _localizePageInitialized = false;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;
  bool _hasInternetAccess = true;

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    _checkInitialConnectivity();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _handleConnectivityChange,
    );

    // Lancer le refresh automatique au premier rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutomaticRefresh();
    });
  }

  Future<void> _startAutomaticRefresh() async {
    await RefreshService.startAutomaticRefresh(
      context: context,
      setLoading: (value) => setState(() => _isLoading = value),
      setRefreshing: (value) => setState(() => _isRefreshing = value),
      isLoading: _isLoading,
      isRefreshing: _isRefreshing,
      localizePageInitialized: _localizePageInitialized,
      selectedIndex: _selectedIndex,
      localizeKey: _localizeKey,
      hideRefreshSnackBar: _hideRefreshSnackBar,
      showSnackBar: _showSnackBar,
    );
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await ConnectivityService.checkInitialConnectivity();
    final connected = ConnectivityService.handleConnectivityChange(results);

    if (!mounted) return;

    setState(() {
      _isOnline = connected;
      _hasInternetAccess = connected;
    });

    if (!connected) {
      _showSnackBar('Aucune connexion internet.', Colors.red);
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    try {
      final connected = ConnectivityService.handleConnectivityChange(results);

      if (!mounted) return;

      final wasOnline = _hasInternetAccess;

      if (_hasInternetAccess == connected) return;

      setState(() {
        _isOnline = connected;
        _hasInternetAccess = connected;
      });

      // Fermer le SnackBar de rafraîchissement si perte de connexion
      if (!connected && _isRefreshing) {
        _hideRefreshSnackBar();
        _showSnackBar(
          'Connexion perdue. Rafraîchissement interrompu.',
          Colors.orange,
        );
      }

      if (!wasOnline && connected) {
        _showSnackBar('Connexion rétablie.', Colors.green);
      } else if (wasOnline && !connected) {
        _showSnackBar(
          'Connexion perdue. Veuillez vérifier votre réseau.',
          Colors.orange,
        );
      }

      // Notifier le changement de connectivité à LocalizePage
      if (_localizeKey.currentState != null) {
        _localizeKey.currentState!.notifyConnectivityChanged(connected);
      }
    } catch (e) {
      debugPrint('Erreur dans _handleConnectivityChange: $e');
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    SnackbarService.showSnackBar(
      context: context,
      message: message,
      backgroundColor: backgroundColor,
    );
  }

  void _hideRefreshSnackBar() {
    RefreshService.hideRefreshSnackBar(context);
  }

  // Méthode pour le bouton reset
  void _onResetPressed() {
    debugPrint('Bouton reset pressé - Index: $_selectedIndex');

    if (_selectedIndex == 0) {
      // Attendre le prochain frame pour éviter les conflits
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_searchPageKey.currentState != null && mounted) {
          try {
            _searchPageKey.currentState?.resetInterface();
          } catch (e, stack) {
            debugPrint('Erreur lors du reset: $e');
            debugPrint('Stack: $stack');
            _showSnackBar('Erreur lors de la réinitialisation', Colors.red);
          }
        } else {
          _showSnackBar('Page de recherche non disponible', Colors.orange);
        }
      });
    } else {
      _showSnackBar(
        'Réinitialisation disponible uniquement sur la page Recherche',
        Colors.orange,
      );
    }
  }

  void _onYearSelectionPressed() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => YearSelectionDialog(
        onDataChanged: () {
          _startAutomaticRefresh(); // ← utilise RefreshService
        },
      ),
    );

    if (result != true) return;
  }

  // Méthode pour le bouton aide
  void _onHelpPressed() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => const HelpDialog(),
    );
    // Ajouter l'action d'aide ici
    _showSnackBar('Aide', Colors.blue);
  }

  Future<void> _onItemTapped(int index) async {
    // PLUS BESOIN d'appeler stopListeningLocation() car géré automatiquement
    // par le LocationManager dans LocalizePage
    setState(() => _selectedIndex = index);

    if (index == 1 && !_localizePageInitialized) {
      setState(() => _localizePageInitialized = true);
      // La gestion de la localisation est maintenant automatique dans LocalizePage
      // via le LocationManager, donc pas besoin d'appeler startListeningLocation()
    }
  }

  Future<void> _onRefresh() async {
    await RefreshService.onRefresh(
      context: context,
      setLoading: (value) => setState(() => _isLoading = value),
      setRefreshing: (value) => setState(() => _isRefreshing = value),
      localizePageInitialized: _localizePageInitialized,
      selectedIndex: _selectedIndex,
      localizeKey: _localizeKey,
      hideRefreshSnackBar: _hideRefreshSnackBar,
      showSnackBar: _showSnackBar,
    );
  }

  @override
  void dispose() {
    // PLUS BESOIN d'appeler stopListeningLocation() car géré automatiquement
    // par le LocationManager dans LocalizePage
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Lato'),
        primaryTextTheme: Theme.of(
          context,
        ).primaryTextTheme.apply(fontFamily: 'Lato'),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedLabelStyle: TextStyle(fontFamily: 'Lato'),
          unselectedLabelStyle: TextStyle(fontFamily: 'Lato'),
        ),
      ),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(
                _appBarTitles[_selectedIndex],
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xff036B54),
              elevation: 0,
              actions: [
                // Bouton Reset
                IconButton(
                  icon: const Icon(
                    Icons.restart_alt, // Icône pour reset
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: _onResetPressed,
                  tooltip: 'Reset', // Info-bulle
                ),

                // Bouton Choix d'année
                IconButton(
                  icon: const Icon(
                    Icons.arrow_downward, // Icône calendrier pour choix d'année
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _onYearSelectionPressed,
                  tooltip: 'Choisir l\'année', // Info-bulle
                ),

                // Bouton Aide (existant)
                IconButton(
                  icon: const Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: 29,
                  ),
                  onPressed: _onHelpPressed,
                  tooltip: 'Aide', // Info-bulle
                ),
              ],
            ),
            body: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _onRefresh,
              color: const Color(0xff036B54),
              child: PrimaryScrollController(
                controller: ScrollController(),
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    SearchPage(key: _searchPageKey),
                    _localizePageInitialized
                        ? LocalizePage(
                            key: _localizeKey,
                            initialIsOnline: _hasInternetAccess,
                          )
                        : const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Initialisation de la localisation...'),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.white,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Rechercher',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.location_on),
                  label: 'Localiser',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xff036B54),
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}

class KeepAliveWidget extends StatefulWidget {
  final Widget child;

  const KeepAliveWidget({super.key, required this.child});

  @override
  State<KeepAliveWidget> createState() => _KeepAliveWidgetState();
}

class _KeepAliveWidgetState extends State<KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
