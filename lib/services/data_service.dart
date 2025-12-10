// lib/services/data_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/etablissement.dart';
import '../utils/excel_parser.dart';
import 'dart:convert';

class DataService {
  static List<Etablissement>? _cachedEtablissements;
  static String? _currentFileName;
  static const String _selectedFileKey = 'selected_excel_file';

  // Obtenir le fichier sélectionné
  static Future<String> getSelectedFileName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedFileKey) ?? 'donnees_2024_2025.xlsx';
  }

  // Sauvegarder le choix
  static Future<void> setSelectedFileName(String fileName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedFileKey, fileName);
    _cachedEtablissements = null;
    _currentFileName = fileName;
  }

  // 🔹 Générer le chemin du cache JSON pour un fichier Excel
  static Future<File> _cacheFileForExcel(String excelFileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final safeName = excelFileName.replaceAll('/', '_');
    return File('${dir.path}/$safeName.json');
  }

  // 🔹 Charger depuis le cache JSON
  static Future<List<Etablissement>> _loadFromJsonCache(
    String excelFileName,
  ) async {
    try {
      final file = await _cacheFileForExcel(excelFileName);
      if (await file.exists()) {
        final jsonStr = await file.readAsString();
        final decoded = jsonDecode(jsonStr) as List;
        final list = decoded.map((e) => Etablissement.fromJson(e)).toList();
        return list.where((e) => e.x != 0 && e.y != 0).toList();
      }
    } catch (e) {
      debugPrint('⚠️ Lecture cache JSON échouée: $e');
    }
    return [];
  }

  // Charger les établissements
  static Future<List<Etablissement>> getEtablissements() async {
    final selectedFile = await getSelectedFileName();

    if (_cachedEtablissements != null && _currentFileName == selectedFile) {
      return _cachedEtablissements!;
    }

    debugPrint('📥 Chargement depuis: $selectedFile');

    // 1️⃣ Essayer le cache JSON
    final cached = await _loadFromJsonCache(selectedFile);
    if (cached.isNotEmpty) {
      _cachedEtablissements = cached;
      _currentFileName = selectedFile;
      debugPrint('✅ Chargé depuis cache JSON: ${cached.length} établissements');
      return cached;
    }

    // 2️⃣ Sinon: parser Excel
    try {
      final byteData = await rootBundle.load('data/$selectedFile');
      final bytes = byteData.buffer.asUint8List();
      final list = await compute(parseExcelInIsolate, bytes);

      _cachedEtablissements = list.where((e) => e.x != 0 && e.y != 0).toList();
      _currentFileName = selectedFile;

      // Sauvegarder en cache JSON pour la prochaine fois
      await _saveJsonCache(selectedFile, _cachedEtablissements!);

      return _cachedEtablissements!;
    } catch (e) {
      debugPrint('❌ Erreur avec $selectedFile: $e');

      // Fallback: essayer un autre fichier disponible
      final availableFiles = await getAvailableExcelFiles();
      if (availableFiles.isNotEmpty && availableFiles[0] != selectedFile) {
        debugPrint('🔄 Essai avec un autre fichier: ${availableFiles[0]}');
        return await loadEtablissementsFromFile(availableFiles[0]);
      }

      rethrow;
    }
  }

  // Charger un fichier spécifique
  static Future<List<Etablissement>> loadEtablissementsFromFile(
    String fileName,
  ) async {
    debugPrint('🔄 Chargement du fichier: $fileName');

    final byteData = await rootBundle.load('data/$fileName');
    final bytes = byteData.buffer.asUint8List();
    final list = await compute(parseExcelInIsolate, bytes);

    _cachedEtablissements = list.where((e) => e.x != 0 && e.y != 0).toList();
    _currentFileName = fileName;

    await setSelectedFileName(fileName);

    // Sauvegarder en cache JSON
    await _saveJsonCache(fileName, _cachedEtablissements!);

    return _cachedEtablissements!;
  }

  // Scanner DYNAMIQUEMENT les fichiers Excel dans data/
  static Future<List<String>> getAvailableExcelFiles() async {
    debugPrint('🔍 Scan dynamique des fichiers Excel...');

    List<String> excelFiles = [];

    try {
      // TOUJOURS scanner le dossier data/, même sur web on peut avoir une fallback
      if (!kIsWeb) {
        // Mobile/Desktop : scan du filesystem
        final dataDir = Directory('data');

        if (await dataDir.exists()) {
          final items = await dataDir.list().toList();

          for (var item in items) {
            try {
              final stat = await item.stat();
              if (stat.type == FileSystemEntityType.file) {
                final path = item.path;
                final fileName = path.split(Platform.pathSeparator).last;

                // Vérifier si c'est un fichier Excel
                if (fileName.toLowerCase().endsWith('.xlsx')) {
                  excelFiles.add(fileName);
                  debugPrint('   ✅ Fichier Excel détecté: $fileName');
                }
              }
            } catch (e) {
              debugPrint('   ⚠️ Erreur avec ${item.path}: $e');
            }
          }
        } else {
          debugPrint('❌ Dossier data/ non trouvé');
        }
      } else {
        // Web : on ne peut pas scanner le filesystem
        // Mais on peut essayer de charger dynamiquement depuis les assets
        debugPrint('🌐 Mode Web - Scan limité');

        // Essayons de détecter les fichiers disponibles
        // Cette partie est limitée sur web
        try {
          // On essaie de charger le fichier par défaut
          await rootBundle.load('data/donnees_2024_2025.xlsx');
          excelFiles.add('donnees_2024_2025.xlsx');
        } catch (e) {
          debugPrint('   ⚠️ donnees_2024_2025.xlsx non trouvé');
        }

        // Vous pouvez ajouter d'autres fichiers connus si nécessaire
        // Mais l'idéal est que l'utilisateur web ait tous les fichiers dans pubspec.yaml
      }

      // Si AUCUN fichier trouvé, on tente une dernière méthode
      if (excelFiles.isEmpty) {
        debugPrint('⚠️ Aucun fichier détecté, vérification manuelle...');

        // Liste des fichiers POTENTIELS basée sur le pattern habituel
        final potentialFiles = [
          'donnees_2023_2024.xlsx',
          'donnees_2024_2025.xlsx',
          'donnees_2025_2026.xlsx',
          'donnees_2026_2027.xlsx',
        ];

        // Vérifier chacun
        for (var file in potentialFiles) {
          try {
            await rootBundle.load('data/$file');
            excelFiles.add(file);
            debugPrint('   ✅ $file existe dans les assets');
          } catch (e) {
            // Le fichier n'existe pas, c'est normal
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur critique lors du scan: $e');
    }

    // Si vraiment aucun fichier, on met au moins le fichier par défaut
    if (excelFiles.isEmpty) {
      debugPrint('⚠️⚠️ AUCUN FICHIER EXCEL TROUVÉ !');
      excelFiles = ['donnees_2024_2025.xlsx'];
    }

    // Trier par nom (décroissant pour avoir les plus récents en premier)
    excelFiles.sort((a, b) => b.compareTo(a));

    debugPrint('📋 Résultat final: ${excelFiles.length} fichiers');
    for (var file in excelFiles) {
      debugPrint('   📄 $file');
    }

    return excelFiles;
  }

  // Méthode alternative PLUS SIMPLE pour le scan
  static Future<List<String>> scanExcelFiles() async {
    debugPrint('🔄 Méthode de scan simplifiée');

    final List<String> foundFiles = [];

    try {
      // Cette méthode tente de charger chaque fichier potentiel
      // C'est moins élégant mais plus fiable sur toutes les plateformes

      // Pattern des noms de fichiers possibles
      final patterns = [
        // Pattern: donnees_AAAA_AAAA.xlsx
        for (int year = 2020; year <= 2030; year++)
          'donnees_${year}_${year + 1}.xlsx',

        // Pattern: data_AAAA_AAAA.xlsx
        for (int year = 2020; year <= 2030; year++)
          'data_${year}_${year + 1}.xlsx',

        // Noms spécifiques
        'donnees.xlsx',
        'data.xlsx',
        'ecoles.xlsx',
        'etablissements.xlsx',
      ];

      debugPrint('🔎 Vérification de ${patterns.length} patterns...');

      // Vérifier chaque pattern
      for (var fileName in patterns) {
        try {
          await rootBundle.load('data/$fileName');
          foundFiles.add(fileName);
          debugPrint('   ✅ $fileName - EXISTE');
        } catch (e) {
          // Fichier non trouvé, c'est normal
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du scan simplifié: $e');
    }

    // Si aucun fichier trouvé, essayer une dernière fois avec le fichier par défaut
    if (foundFiles.isEmpty) {
      debugPrint(
        '⚠️ Aucun fichier détecté, vérification du fichier par défaut',
      );
      try {
        await rootBundle.load('data/donnees_2024_2025.xlsx');
        foundFiles.add('donnees_2024_2025.xlsx');
      } catch (e) {
        debugPrint('❌ Même le fichier par défaut est introuvable !');
      }
    }

    foundFiles.sort((a, b) => b.compareTo(a));
    return foundFiles;
  }

  static Future<void> _saveJsonCache(
    String excelFileName,
    List<Etablissement> list,
  ) async {
    try {
      final file = await _cacheFileForExcel(excelFileName);
      final data = list.map((e) => e.toJson()).toList();
      final jsonStr = jsonEncode(data);
      await file.writeAsString(jsonStr);
      debugPrint('💾 Cache JSON sauvegardé pour $excelFileName');
    } catch (e) {
      debugPrint('⚠️ Sauvegarde cache JSON échouée: $e');
    }
  }
}
