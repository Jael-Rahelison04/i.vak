// widgets/school_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../model/etablissement.dart';
import '../../services/phone_service.dart';
import '../../services/share_service.dart';
import '../../services/itinerary_service.dart';

class SchoolBottomSheet extends StatelessWidget {
  final Etablissement etablissement;
  final VoidCallback onClose;
  final LatLng userPosition;
  final BuildContext parentContext;
  final Function(Etablissement) onStartNavigation;

  // Plus besoin du static GlobalKey dangereux. On utilisera le ScaffoldMessenger contextuel.

  const SchoolBottomSheet({
    super.key,
    required this.etablissement,
    required this.onClose,
    required this.userPosition,
    required this.parentContext,
    required this.onStartNavigation,
  });

  void _startNavigation(BuildContext context) {
    Navigator.of(context).pop();
    Future.delayed(const Duration(milliseconds: 300), () {
      onStartNavigation(etablissement);
    });
  }

  // Sécurisation de la SnackBar en capturant le ScaffoldMessenger avant l'action asynchrone
  Future<void> _shareSchoolInfo(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await ShareService.shareSchoolInfo(
      etablissement: etablissement,
      showSnackBar: (message) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }

  String formatNiveau(String niveau) {
    const mapNiveaux = {
      'prescolaire': 'Préscolaire',
      'niveau_i': 'Niveau I',
      'niveau_ii': 'Niveau II',
      'niveau_iii': 'Niveau III',
    };
    return mapNiveaux[niveau.toLowerCase()] ?? niveau;
  }

  // --- UI BUILDERS ---

  Widget _buildInfoRow(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Remplacement de tes 3 pavés de boutons par une seule méthode propre et anti-overflow
  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        // FittedBox empêche le texte de déborder sur les petits écrans
        label: FittedBox(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xff036B54),
          side: const BorderSide(color: Color(0xff036B54), width: 2),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 4,
          ), // Padding réduit pour l'espace
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Entête corrigée (Poignée centrée et bouton à droite)
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(width: double.infinity, height: 40), // Zone de clic
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      onClose();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etablissement.nom_etab,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff036B54),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${etablissement.secteur} - ${formatNiveau(etablissement.niveau)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // Panneau d'itinéraire
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xff036B54)),
                  ),
                  child: FutureBuilder<Map<String, String>>(
                    future: ItineraryService.loadTripInfo(
                      userPos: userPosition,
                      etab: etablissement,
                      context: parentContext,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xff036B54),
                          ),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Text(
                          'Calcul indisponible',
                          style: TextStyle(color: Colors.grey),
                        );
                      }

                      final info = snapshot.data!;
                      return Column(
                        children: [
                          _buildInfoRow(
                            Icons.location_on,
                            Colors.red.shade600,
                            'Distance',
                            info['distance']!,
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            Icons.directions_car,
                            Colors.blue.shade700,
                            'En voiture',
                            info['driving']!,
                          ),
                          _buildInfoRow(
                            Icons.directions_bus,
                            Colors.purple.shade600,
                            'Transports',
                            info['transit']!,
                          ),
                          _buildInfoRow(
                            Icons.directions_walk,
                            Colors.green.shade700,
                            'À pied',
                            info['walking']!,
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Les 3 boutons optimisés
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      label: 'Itinéraire',
                      icon: Icons.directions,
                      onPressed: () => _startNavigation(context),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      context,
                      label: 'Appeler',
                      icon: Icons.phone,
                      onPressed: () => PhoneService.makePhoneCall(
                        context: context,
                        phoneNumber: etablissement.contact_directeur,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      context,
                      label: 'Partager',
                      icon: Icons.share,
                      onPressed: () => _shareSchoolInfo(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
