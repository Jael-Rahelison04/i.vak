// lib/services/data_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/etablissement.dart';
import '../utils/excel_parser.dart';

class DataService {
  static List<Etablissement>? _cachedEtablissements;
  static String? _currentFileName;
  static const String _selectedFileKey = 'selected_excel_file';

  // --- CONFIGURATION GITHUB ---
  static const String _owner = "i-vak";
  static const String _repo = "annuaire_data";
  static const String _branch = "main";

  // URL de l'API GitHub pour lister le contenu du dépôt
  static const String _apiUrl =
      "https://api.github.com/repos/$_owner/$_repo/contents/";

  /// Vérifie si le fichier sélectionné existe localement
  static Future<bool> hasLocalData() async {
    final selectedFile = await getSelectedFileName();
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$selectedFile').exists();
  }

  /// 📥 Télécharge un fichier Excel depuis le dépôt GitHub Public
  static Future<bool> downloadExcelFile(String fileName) async {
    // Construction de l'URL RAW (contenu brut du fichier)
    final rawUrl =
        "https://raw.githubusercontent.com/$_owner/$_repo/$_branch/$fileName";

    try {
      final response = await http.get(Uri.parse(rawUrl));

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('✅ Fichier GitHub téléchargé: $fileName');
        return true;
      } else {
        debugPrint('❌ Échec du téléchargement GitHub: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du téléchargement GitHub: $e');
      return false;
    }
  }

  /// 🔍 Liste les fichiers .xlsx disponibles sur le repository GitHub
  static Future<List<String>> getCloudExcelFiles() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'User-Agent': 'i_vak_app', // Requis par l'API GitHub
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        // On filtre : type 'file' et extension '.xlsx'
        final excelFiles = jsonResponse
            .where(
              (item) =>
                  item['type'] == 'file' &&
                  item['name'].toString().toLowerCase().endsWith('.xlsx'),
            )
            .map((item) => item['name'].toString())
            .toList();

        // Tri pour avoir les années les plus récentes en haut
        excelFiles.sort((a, b) => b.compareTo(a));
        debugPrint('📦 Fichiers trouvés sur GitHub: ${excelFiles.length}');
        return excelFiles;
      } else {
        debugPrint('❌ Erreur API GitHub: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du scan GitHub: $e');
      return [];
    }
  }

  /// Liste les fichiers déjà présents sur le téléphone
  static Future<List<String>> getAvailableExcelFiles() async {
    List<String> excelFiles = [];
    try {
      final directory = await getApplicationDocumentsDirectory();
      if (await directory.exists()) {
        final List<FileSystemEntity> entities = await directory.list().toList();
        for (var entity in entities) {
          if (entity is File && entity.path.toLowerCase().endsWith('.xlsx')) {
            excelFiles.add(entity.path.split(Platform.pathSeparator).last);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du scan local: $e');
    }
    excelFiles.sort((a, b) => b.compareTo(a));
    return excelFiles;
  }

  // --- LOGIQUE DE CACHE ET CHARGEMENT (Inchangée mais optimisée) ---

  static Future<String> getSelectedFileName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedFileKey) ?? 'donnees_2024_2025.xlsx';
  }

  static Future<void> setSelectedFileName(String fileName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedFileKey, fileName);
    _cachedEtablissements = null;
    _currentFileName = fileName;
  }

  static Future<List<Etablissement>> getEtablissements() async {
    final selectedFile = await getSelectedFileName();

    if (_cachedEtablissements != null && _currentFileName == selectedFile) {
      return _cachedEtablissements!;
    }

    // Essayer le cache JSON
    final cached = await _loadFromJsonCache(selectedFile);
    if (cached.isNotEmpty) {
      _cachedEtablissements = cached;
      _currentFileName = selectedFile;
      return cached;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$selectedFile');

      if (!await file.exists()) {
        debugPrint('⚠️ Aucun fichier local. L\'app démarre vide.');
        return [];
      }

      final bytes = await file.readAsBytes();
      final list = await compute(parseExcelInIsolate, bytes);

      _cachedEtablissements = list.where((e) => e.x != 0 && e.y != 0).toList();
      _currentFileName = selectedFile;

      await _saveJsonCache(selectedFile, _cachedEtablissements!);
      return _cachedEtablissements!;
    } catch (e) {
      debugPrint('❌ Erreur chargement: $e');
      return [];
    }
  }

  static Future<File> _cacheFileForExcel(String excelFileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/${excelFileName.replaceAll('/', '_')}.json');
  }

  static Future<List<Etablissement>> _loadFromJsonCache(
    String excelFileName,
  ) async {
    try {
      final file = await _cacheFileForExcel(excelFileName);
      if (await file.exists()) {
        final jsonStr = await file.readAsString();
        final decoded = jsonDecode(jsonStr) as List;
        return decoded.map((e) => Etablissement.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ Erreur cache JSON: $e');
    }
    return [];
  }

  static Future<void> _saveJsonCache(
    String excelFileName,
    List<Etablissement> list,
  ) async {
    try {
      final file = await _cacheFileForExcel(excelFileName);
      final jsonStr = jsonEncode(list.map((e) => e.toJson()).toList());
      await file.writeAsString(jsonStr);
    } catch (e) {
      debugPrint('⚠️ Erreur sauvegarde cache: $e');
    }
  }

  static Future<bool> isFileDownloaded(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName').exists();
  }
}
