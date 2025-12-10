import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class DialogService {
  static Future<bool> showHighAccuracyDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Précision de localisation'),
            content: const Text(
              'Pour une localisation optimale, activez la "Précision élevée" dans les paramètres.\n\n'
              'Cela utilise le GPS, le Wi-Fi et le Bluetooth.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Ignorer'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                  await Geolocator.openLocationSettings();
                },
                child: const Text('Activer'),
              ),
            ],
          ),
        ) ??
        false;
  }

  static Future<bool> showPermissionExplanationDialog(
    BuildContext context,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permission de localisation nécessaire'),
        content: const Text(
          'Cette application a besoin de la permission de localisation pour fonctionner correctement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Autoriser'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: () => onAction?.call(),
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showArrivalNotification(BuildContext context) {
    showSnackBar(
      context,
      '🎉 Vous êtes arrivé à destination !',
      actionLabel: 'OK',
      onAction: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    );
  }
}
