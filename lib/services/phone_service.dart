import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PhoneService {
  static final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  static Future<void> makePhoneCall({
    required BuildContext context, // Utiliser le contexte passé en paramètre
    required String phoneNumber,
  }) async {
    // Validation préalable
    if (!await _canDeviceMakeCalls(context)) {
      _showErrorSnackBar(context, 'Cet appareil ne peut pas passer d\'appels');
      return;
    }

    // Nettoyer et valider le numéro
    final String cleanedNumber = _cleanPhoneNumber(phoneNumber);

    if (!_isValidPhoneNumber(cleanedNumber)) {
      _showErrorSnackBar(context, 'Numéro de téléphone invalide');
      return;
    }

    // Vérifier les permissions (Android)
    if (!await _hasPhonePermission(context)) {
      _showErrorSnackBar(context, 'Permission d\'appel requise');
      return;
    }

    await _launchPhoneCall(cleanedNumber, context);
  }

  static String _cleanPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';
    return phoneNumber.replaceAll(RegExp(r'[^\d+]'), '').trim();
  }

  static bool _isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;

    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 8 || digitsOnly.length > 15) {
      return false;
    }

    final validPatterns = [
      RegExp(r'^\+?[1-9]\d{1,14}$'),
      RegExp(r'^0[1-9]\d{8}$'),
      RegExp(r'^[1-9]\d{7,14}$'),
    ];

    return validPatterns.any((pattern) => pattern.hasMatch(phoneNumber));
  }

  static Future<bool> _canDeviceMakeCalls(BuildContext context) async {
    try {
      final deviceInfo = await _getDeviceInfo(context);

      // Vérifier si c'est un émulateur
      if (deviceInfo['isEmulator'] == true) {
        return false;
      }

      // Pour Android, vérifier si l'appareil est un téléphone
      if (deviceInfo['isAndroid'] == true) {
        return deviceInfo['hasTelephony'] == true;
      }

      return true;
    } catch (e) {
      return true; // Fallback safe
    }
  }

  static Future<Map<String, dynamic>> _getDeviceInfo(
    BuildContext context,
  ) async {
    try {
      final map = <String, dynamic>{};

      // Utiliser le contexte passé en paramètre au lieu de navigatorKey
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        map['isAndroid'] = true;
        map['isEmulator'] = !androidInfo.isPhysicalDevice;
        map['hasTelephony'] = androidInfo.isPhysicalDevice;
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        map['isIOS'] = true;
        map['isEmulator'] = !iosInfo.isPhysicalDevice;
      }

      return map;
    } catch (e) {
      return {'isEmulator': false};
    }
  }

  static Future<bool> _hasPhonePermission(BuildContext context) async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      final status = await Permission.phone.status;
      if (!status.isGranted) {
        final result = await Permission.phone.request();
        return result.isGranted;
      }
      return true;
    }
    return true; // iOS
  }

  static Future<void> _launchPhoneCall(
    String cleanedNumber,
    BuildContext context,
  ) async {
    try {
      bool launchSuccessful = false;

      // ÉTAPE 1: Essayer 'telprompt' (iOS)
      final telPromptUri = Uri(scheme: 'telprompt', path: cleanedNumber);
      if (await canLaunchUrl(telPromptUri)) {
        launchSuccessful = await launchUrl(telPromptUri);
      }

      // ÉTAPE 2: Fallback sur 'tel' (Android/iOS)
      if (!launchSuccessful) {
        final telUri = Uri(scheme: 'tel', path: cleanedNumber);
        if (await canLaunchUrl(telUri)) {
          launchSuccessful = await launchUrl(telUri);
        }
      }

      // ÉTAPE 3: Fallback avec intent (Android spécifique)
      if (!launchSuccessful) {
        final intentUri = Uri(
          scheme: 'intent',
          path: 'tel:$cleanedNumber',
          queryParameters: {'package': 'com.android.phone'},
        );
        if (await canLaunchUrl(intentUri)) {
          launchSuccessful = await launchUrl(intentUri);
        }
      }

      // ÉTAPE 4: Fallback direct avec launchUrl sans vérification
      if (!launchSuccessful) {
        try {
          final telUri = Uri(scheme: 'tel', path: cleanedNumber);
          await launchUrl(telUri);
          launchSuccessful = true;
        } catch (e) {
          launchSuccessful = false;
        }
      }

      if (!launchSuccessful) {
        _showErrorSnackBar(context, 'Impossible de lancer l\'appel');
        debugPrint('Échec de l\'appel pour le numéro: $cleanedNumber');

        // Afficher plus d'informations de débogage
        debugPrint('URI testées:');
        debugPrint('telprompt:$cleanedNumber');
        debugPrint('tel:$cleanedNumber');
        debugPrint('intent://tel:$cleanedNumber');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Erreur lors de l\'appel: ${e.toString()}');
      debugPrint('Erreur d\'appel: $e');
    }
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Méthode utilitaire pour formater le numéro pour l'affichage
  static String formatPhoneNumberForDisplay(String phoneNumber) {
    final cleaned = _cleanPhoneNumber(phoneNumber);

    if (cleaned.startsWith('+')) {
      return cleaned.replaceAllMapped(
        RegExp(r'^(\+\d{3})(\d{2})(\d{2})(\d{3})(\d{2})$'),
        (Match m) => '${m[1]} ${m[2]} ${m[3]} ${m[4]} ${m[5]}',
      );
    } else if (cleaned.startsWith('0')) {
      return cleaned.replaceAllMapped(
        RegExp(r'^(\d{2})(\d{2})(\d{3})(\d{2})$'),
        (Match m) => '${m[1]} ${m[2]} ${m[3]} ${m[4]}',
      );
    }

    return cleaned;
  }

  static bool isLikelyMalagasyNumber(String phoneNumber) {
    final cleaned = _cleanPhoneNumber(phoneNumber);
    return cleaned.startsWith('+261') ||
        cleaned.startsWith('261') ||
        cleaned.startsWith('0');
  }

  // Dans PhoneService class
  static List<String> extractPhoneNumbers(String phoneData) {
    if (phoneData.isEmpty) return [];

    // Séparer par "/" ou autres séparateurs courants
    final separators = ['/', ',', ';', 'et', '&'];
    String cleanedData = phoneData.trim();

    // Remplacer tous les séparateurs par "/" pour uniformiser
    for (var separator in separators) {
      cleanedData = cleanedData.replaceAll(separator, '/');
    }

    // Diviser en numéros individuels
    final rawNumbers = cleanedData.split('/').map((num) => num.trim()).toList();

    // Nettoyer chaque numéro et garder seulement les valides
    final validNumbers = <String>[];
    for (var number in rawNumbers) {
      final cleaned = _cleanPhoneNumber(number);
      if (_isValidPhoneNumber(cleaned)) {
        validNumbers.add(cleaned);
      }
    }

    return validNumbers;
  }

  // Méthode pour formater un numéro unique avec espacements esthétiques
  static String formatSingleNumber(String phoneNumber) {
    final cleaned = _cleanPhoneNumber(phoneNumber);

    if (cleaned.startsWith('+261')) {
      // Format international: +261 34 12 345 67
      if (cleaned.length == 12) {
        // +261341234567
        return '+261 ${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 11)} ${cleaned.substring(11)}';
      }
    } else if (cleaned.startsWith('261')) {
      // Format sans +: 261 34 12 345 67
      if (cleaned.length == 11) {
        // 261341234567
        return '261 ${cleaned.substring(3, 5)} ${cleaned.substring(5, 7)} ${cleaned.substring(7, 10)} ${cleaned.substring(10)}';
      }
    } else if (cleaned.startsWith('0')) {
      // Format national: 034 12 345 67
      if (cleaned.length == 10) {
        // 0341234567
        return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 5)} ${cleaned.substring(5, 8)} ${cleaned.substring(8)}';
      }
    }

    // Fallback: retourner le numéro original si le format n'est pas reconnu
    return cleaned;
  }

  // Méthode pour formater tous les numéros d'un contact
  static List<String> formatPhoneNumbers(String phoneData) {
    final numbers = extractPhoneNumbers(phoneData);
    return numbers.map(formatSingleNumber).toList();
  }
}
