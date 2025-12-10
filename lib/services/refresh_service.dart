import 'package:flutter/material.dart';
import 'package:annuaire_scolaire/services/data_service.dart';
import 'package:annuaire_scolaire/pages/localize.dart';

class RefreshService {
  static Future<void> startAutomaticRefresh({
    required BuildContext context,
    required Function(bool) setLoading,
    required Function(bool) setRefreshing,
    required bool isLoading,
    required bool isRefreshing,
    required bool localizePageInitialized,
    required int selectedIndex,
    required GlobalKey<LocalizePageState> localizeKey,
    required Function() hideRefreshSnackBar,
    required Function(String, Color) showSnackBar,
  }) async {
    if (isLoading || isRefreshing) return;

    setLoading(true);

    _showRefreshSnackBar(context);

    try {
      setRefreshing(true);

      try {
        // 1. Recharger les données (met à jour le cache)
        final list = await DataService.getEtablissements();

        // 2. Forcer la mise à jour dans LocalizePage
        if (localizePageInitialized) {
          localizeKey.currentState?.updateEtablissements(list);
        }

        // 3. CORRIGÉ : Utiliser refreshLocation() au lieu de stopListeningLocation()
        if (selectedIndex == 1 && localizePageInitialized) {
          // La gestion de la localisation est maintenant automatique via LocationManager
          // On appelle simplement refreshLocation() pour forcer une mise à jour
          localizeKey.currentState?.refreshLocation();
        }
      } catch (e) {
        // En cas d'erreur, fermer le SnackBar de rafraîchissement et afficher l'erreur
        hideRefreshSnackBar();
        showSnackBar('Erreur lors du rafraîchissement', Colors.red);
      } finally {
        await Future.delayed(const Duration(milliseconds: 600));
        setRefreshing(false);
      }
      debugPrint('Refresh automatique terminé');
    } finally {
      setLoading(false);
      hideRefreshSnackBar();
    }
  }

  static Future<void> onRefresh({
    required BuildContext context,
    required Function(bool) setLoading,
    required Function(bool) setRefreshing,
    required bool localizePageInitialized,
    required int selectedIndex,
    required GlobalKey<LocalizePageState> localizeKey,
    required Function() hideRefreshSnackBar,
    required Function(String, Color) showSnackBar,
  }) async {
    setLoading(true);

    _showRefreshSnackBar(context);

    try {
      setRefreshing(true);

      try {
        // 1. Recharger les données (met à jour le cache)
        final list = await DataService.getEtablissements();

        // 2. Forcer la mise à jour dans LocalizePage
        if (localizePageInitialized) {
          localizeKey.currentState?.updateEtablissements(list);
        }

        // 3. CORRIGÉ : Utiliser refreshLocation() au lieu de stopListeningLocation()
        if (selectedIndex == 1 && localizePageInitialized) {
          // La gestion de la localisation est maintenant automatique via LocationManager
          // On appelle simplement refreshLocation() pour forcer une mise à jour
          localizeKey.currentState?.refreshLocation();
        }
      } catch (e) {
        // En cas d'erreur, fermer le SnackBar de rafraîchissement et afficher l'erreur
        hideRefreshSnackBar();
        showSnackBar('Erreur lors du rafraîchissement', Colors.red);
      } finally {
        await Future.delayed(const Duration(milliseconds: 600));
        setRefreshing(false);
      }
      debugPrint('Refresh terminé');
    } finally {
      setLoading(false);
      hideRefreshSnackBar();
    }
  }

  static void _showRefreshSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Rafraîchissement en cours, veuillez patienter...',
                style: TextStyle(color: Colors.white, fontFamily: 'Lato'),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xff036B54).withOpacity(0.75),
        duration: const Duration(hours: 1),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  static void hideRefreshSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
