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

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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

  // === FONCTION POUR LE PARTAGE ===
  Future<void> _shareSchoolInfo() async {
    await ShareService.shareSchoolInfo(
      etablissement: etablissement,
      showSnackBar: _showSnackBar,
    );
  }

  void _showSnackBar(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
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
    );
  }

  String formatNiveau(String niveau) {
    switch (niveau.toLowerCase()) {
      case 'prescolaire':
        return 'Préscolaire';
      case 'niveau_i':
        return 'Niveau I';
      case 'niveau_ii':
        return 'Niveau II';
      case 'niveau_iii':
        return 'Niveau III';
      default:
        return niveau;
    }
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
          // Barre de tirage + bouton fermer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    onClose();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etablissement.nom_etab,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                    color: Color(0xff036B54),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${etablissement.secteur} - ${formatNiveau(etablissement.niveau)}',
                  style: TextStyle(color: Colors.grey[600], fontFamily: 'Lato'),
                ),
                const SizedBox(height: 24),
                // === NOUVEAU CONTENU : DISTANCE + TEMPS DE TRAJET ===
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xff036B54)),
                  ),
                  child: FutureBuilder<Map<String, String>>(
                    future: ItineraryService.loadTripInfo(
                      userPos: userPosition,
                      etab: etablissement,
                      context: parentContext,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final info = snapshot.data!;
                        return Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.location_on,
                              color: Colors.red.shade600,
                              label: 'Distance',
                              value: info['distance']!,
                            ),
                            const Divider(height: 20),
                            _buildInfoRow(
                              icon: Icons.directions_car,
                              color: Colors.blue.shade700,
                              label: 'En voiture',
                              value: info['driving']!,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              icon: Icons.directions_bus,
                              color: Colors.purple.shade600,
                              label: 'Transports',
                              value: info['transit']!,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              icon: Icons.directions_walk,
                              color: Colors.green.shade700,
                              label: 'À pied',
                              value: info['walking']!,
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return const Text(
                          'Calcul en cours...',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // BOUTON 1 : Itinéraire
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _startNavigation(context),
                        icon: const Icon(Icons.directions, size: 20),
                        label: const Text(
                          'Itinéraire',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xff036B54),
                          shadowColor: Colors.transparent,
                          side: const BorderSide(
                            color: Color(0xff036B54),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // BOUTON 2 : Appeler
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => PhoneService.makePhoneCall(
                          context: context, // Passer le contexte actuel
                          phoneNumber: etablissement.contact_directeur,
                        ),
                        icon: const Icon(Icons.phone, size: 20),
                        label: const Text(
                          'Appeler',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xff036B54),
                          shadowColor: Colors.transparent,
                          side: const BorderSide(
                            color: Color(0xff036B54),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // BOUTON 3 : Partager
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _shareSchoolInfo,
                        icon: const Icon(Icons.share, size: 20),
                        label: const Text(
                          'Partager',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xff036B54),
                          shadowColor: Colors.transparent,
                          side: const BorderSide(
                            color: Color(0xff036B54),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),
        ],
      ),
    );
  }
}
