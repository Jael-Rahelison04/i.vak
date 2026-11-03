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

  Map<String, bool> _loadingStatus = {};

  bool _isLoading = false;

  Map<String, bool> _downloadedStatus = {};

  Future<void> _loadDownloadedStatus(List<String> files) async {
    final Map<String, bool> status = {};
    for (final file in files) {
      final isDownloaded = await DataService.isFileDownloaded(file);
      status[file] = isDownloaded;
    }
    setState(() {
      _downloadedStatus = status;
    });
  }

  // Dans _YearSelectionDialogState
  @override
  void initState() {
    super.initState();
    _availableFilesFuture = DataService.getCloudExcelFiles(); // ← inclut Cloud
    //_availableFilesFuture = DataService.scanExcelFiles();
    _loadCurrentSelection();
    _availableFilesFuture.then((files) {
      _loadDownloadedStatus(files);
    });
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
              debugPrint(
                '⚠️ GitHub accessible mais aucun fichier Excel détecté',
              );
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, color: Colors.orange, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun fichier Excel trouvé\nsur le serveur en ligne.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vérifiez le dépôt GitHub.',
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
                  final isDownloaded = _downloadedStatus[fileName] ?? false;
                  final isLoading = _loadingStatus[fileName] ?? false;

                  return ListTile(
                    title: Text(_formatFileName(fileName)),
                    subtitle: Text(
                      fileName,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xff036B54),
                            ),
                          )
                        : isDownloaded
                        ? Radio<String>(
                            value: fileName,
                            groupValue: _selectedFile,
                            onChanged: (value) {
                              setState(() => _selectedFile = value);
                            },
                            activeColor: const Color(0xff036B54),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.download_rounded,
                              color: Color(0xff036B54),
                            ),
                            onPressed: () async {
                              setState(() {
                                _loadingStatus[fileName] = true;
                              });
                              final success =
                                  await DataService.downloadExcelFile(fileName);
                              if (success) {
                                await _loadDownloadedStatus(snapshot.data!);
                                setState(() {
                                  _selectedFile = fileName;
                                  _loadingStatus[fileName] = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Fichier $fileName téléchargé avec succès',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                setState(() {
                                  _loadingStatus[fileName] = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Échec du téléchargement de $fileName',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                  );
                }).toList(),
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
          onPressed:
              _isLoading ||
                  _selectedFile == null ||
                  !(_downloadedStatus[_selectedFile] ?? false)
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
