import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Tes services et widgets
import 'package:annuaire_scolaire/services/data_service.dart';
import 'package:annuaire_scolaire/services/connectivity_service.dart';
import 'package:annuaire_scolaire/services/refresh_service.dart';
import 'package:annuaire_scolaire/services/snackbar_service.dart';
import 'package:annuaire_scolaire/widgets/help_dialog.dart';
import 'package:annuaire_scolaire/widgets/search_gate.dart';
import 'package:annuaire_scolaire/widgets/year_selection_dialog.dart';
import 'package:annuaire_scolaire/pages/search.dart';
import 'package:annuaire_scolaire/pages/localize.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Constantes de style
  static const Color _primaryColor = Color(0xff036B54);

  // État de l'UI
  int _selectedIndex = 0;
  // ignore: unused_field
  bool _isLoading = false;
  // ignore: unused_field
  bool _isRefreshing = false;
  bool _localizeInitialized = false;

  // Notifier pour éviter de reconstruire tout le Scaffold si juste la donnée change
  final ValueNotifier<bool> _noDataNotifier = ValueNotifier<bool>(false);

  // Clés et Souscriptions
  final GlobalKey<SearchPageState> _searchPageKey =
      GlobalKey<SearchPageState>();
  final GlobalKey<LocalizePageState> _localizeKey =
      GlobalKey<LocalizePageState>();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  void _initApp() async {
    // 1. Connectivité
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      _updateConnectivity,
    );

    // 2. Vérification données locales
    bool hasData = await DataService.hasLocalData();
    _noDataNotifier.value = !hasData;

    if (hasData) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshData());
    }
  }

  void _updateConnectivity(List<ConnectivityResult> results) {
    final isOnline = ConnectivityService.handleConnectivityChange(results);
    if (!mounted) return;

    // Notifier la page Localize si elle existe
    _localizeKey.currentState?.notifyConnectivityChanged(isOnline);

    if (!isOnline) {
      _showSnackBar('Mode hors-ligne activé', Colors.orange);
    }
  }

  Future<void> _refreshData() async {
    if (_noDataNotifier.value) return;

    await RefreshService.onRefresh(
      context: context,
      setLoading: (v) => setState(() => _isLoading = v),
      setRefreshing: (v) => setState(() => _isRefreshing = v),
      localizePageInitialized: _localizeInitialized,
      selectedIndex: _selectedIndex,
      localizeKey: _localizeKey,
      hideRefreshSnackBar: () => RefreshService.hideRefreshSnackBar(context),
      showSnackBar: _showSnackBar,
    );
  }

  void _onYearSelection() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => YearSelectionDialog(onDataChanged: () {}),
    );

    if (changed == true) {
      _noDataNotifier.value = false;
      _refreshData();
    }
  }

  void _showSnackBar(String msg, Color color) {
    SnackbarService.showSnackBar(
      context: context,
      message: msg,
      backgroundColor: color,
    );
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    _noDataNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ['Rechercher', 'Localiser'][_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _primaryColor,
        actions: [
          // On garde uniquement les actions essentielles, le reste peut aller dans un menu ou au clic long
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _searchPageKey.currentState?.resetInterface(),
            tooltip: 'Réinitialiser la recherche',
          ),
          IconButton(
            icon: const Icon(
              Icons.cloud_download_outlined,
              color: Colors.white,
            ),
            onPressed: _onYearSelection,
            tooltip: 'Changer d\'année',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) => v == 'help'
                ? showDialog(
                    context: context,
                    builder: (_) => const HelpDialog(),
                  )
                : null,
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'help', child: Text('Aide et guide')),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _noDataNotifier,
        builder: (context, noData, _) {
          if (noData) return _buildEmptyState();

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: _primaryColor,
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                SearchGate(searchPageKey: _searchPageKey),
                _buildLocalizeWrapper(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: _primaryColor,
        onTap: (i) {
          setState(() {
            _selectedIndex = i;
            if (i == 1) _localizeInitialized = true;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Carte',
          ),
        ],
      ),
    );
  }

  Widget _buildLocalizeWrapper() {
    if (!_localizeInitialized)
      return const Center(child: CircularProgressIndicator());
    return LocalizePage(key: _localizeKey, initialIsOnline: true);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 70, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            "Aucune donnée installée",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _onYearSelection,
            icon: const Icon(Icons.download),
            label: const Text("Télécharger l'annuaire"),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
