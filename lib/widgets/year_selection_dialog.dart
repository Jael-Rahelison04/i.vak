// lib/widgets/year_selection_dialog.dart
import 'package:flutter/material.dart';
import 'package:annuaire_scolaire/services/data_service.dart';

class YearSelectionDialog extends StatefulWidget {
  final VoidCallback onDataChanged;

  const YearSelectionDialog({super.key, required this.onDataChanged});

  @override
  State<YearSelectionDialog> createState() => _YearSelectionDialogState();
}

class _YearSelectionDialogState extends State<YearSelectionDialog> {
  String? _selectedFile;
  late Future<List<String>> _availableFilesFuture;
  bool _isLoading = false;

  // Dans _YearSelectionDialogState
  @override
  void initState() {
    super.initState();
    // Utiliser scanExcelFiles() au lieu de getAvailableExcelFiles()
    _availableFilesFuture = DataService.scanExcelFiles(); // ← CHANGEMENT ICI
    _loadCurrentSelection();
  }

  Future<void> _loadCurrentSelection() async {
    final currentFile = await DataService.getSelectedFileName();
    setState(() {
      _selectedFile = currentFile;
    });
  }

  String _formatFileName(String fileName) {
    final yearPattern = RegExp(r'\d{4}[-_]\d{4}');
    final match = yearPattern.firstMatch(fileName);

    if (match != null) {
      final years = match.group(0)!.replaceAll('_', '-');
      return 'Année scolaire $years';
    }

    return fileName.replaceAll('.xlsx', '').replaceAll('_', ' ');
  }

  Future<void> _applySelection() async {
    if (_selectedFile == null) return;

    // Sauvegarder le fichier choisi
    await DataService.setSelectedFileName(_selectedFile!);

    // Fermer le dialogue immédiatement
    if (mounted) {
      Navigator.of(context).pop(true);
    }

    // Notifier le parent que les données doivent être rafraîchies
    widget.onDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Sélectionner l\'année scolaire',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xff036B54),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<String>>(
          future: _availableFilesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xff036B54)),
              );
            }

            if (snapshot.hasError || snapshot.data == null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.hasError
                        ? 'Erreur: ${snapshot.error}'
                        : 'Impossible de charger la liste des fichiers',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            final files = snapshot.data!;

            if (files.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.folder_open, color: Colors.orange, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun fichier Excel trouvé\n dans le dossier data/',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez des fichiers .xlsx dans data/',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choisissez l\'année scolaire des données à utiliser:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                ...files.map((fileName) {
                  return RadioListTile<String>(
                    title: Text(
                      _formatFileName(fileName),
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      fileName,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    value: fileName,
                    groupValue: _selectedFile,
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() => _selectedFile = value);
                          },
                    activeColor: const Color(0xff036B54),
                    controlAffinity: ListTileControlAffinity.trailing,
                  );
                }).toList(),
                if (_isLoading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: Color(0xff036B54)),
                  const SizedBox(height: 8),
                  const Text(
                    'Chargement des nouvelles données...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isLoading || _selectedFile == null
              ? null
              : _applySelection,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff036B54),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Appliquer'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
    );
  }
}
