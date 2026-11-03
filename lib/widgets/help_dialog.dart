// widgets/help_dialog.dart
import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 10,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête avec titre centré
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xff036B54),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Text(
                  'À propos de i.vak',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Lato',
                  ),
                ),
              ),
            ),

            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Objectif
                    _buildSection(
                      title: '🎯 Notre mission',
                      content:
                          'i.vak est l\'annuaire numérique officiel conçu pour simplifier l\'accès aux informations des établissements scolaires de la région Vakinankaratra. Notre but est de faciliter l\'orientation et la communication entre les élèves, les parents, le corps enseignant et l\'administration.',
                    ),

                    const SizedBox(height: 24),

                    // Section Fonctionnalités
                    _buildSection(
                      title: '🚀 Fonctionnalités clés',
                      content: '',
                      children: [
                        _buildFeatureItem(
                          icon: Icons.search,
                          text:
                              'Recherche intelligente : Trouvez rapidement un établissement grâce à nos filtres multicritères avancés.',
                        ),
                        _buildFeatureItem(
                          icon: Icons.location_on,
                          text:
                              'Cartographie : Visualisez les écoles sur une carte interactive et générez votre itinéraire en un clic.',
                        ),
                        _buildFeatureItem(
                          icon: Icons.info_outline,
                          text:
                              'Fiches détaillées : Accédez aux informations essentielles (taux de réussite, effectifs, filières proposées).',
                        ),
                        _buildFeatureItem(
                          icon: Icons.wifi_off,
                          text:
                              'Mode hors-ligne : Consultez vos données téléchargées à tout moment, même sans connexion internet (hors cartographie).',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section Comment utiliser
                    _buildSection(
                      title: '📱 Guide d\'utilisation rapide',
                      content: '',
                      children: [
                        _buildStepItem(
                          number: '1',
                          text:
                              'Utilisez l\'onglet "Recherche" pour cibler un établissement précis.',
                        ),
                        _buildStepItem(
                          number: '2',
                          text:
                              'Consultez l\'onglet "Carte" pour une vue géographique des écoles à proximité.',
                        ),
                        _buildStepItem(
                          number: '3',
                          text:
                              'Sélectionnez l\'année scolaire en haut de l\'écran pour actualiser les statistiques.',
                        ),
                        _buildStepItem(
                          number: '4',
                          text:
                              'Glissez l\'écran vers le bas (Pull-to-refresh) pour synchroniser les dernières données.',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section Contact et Support (Nouvelle)
                    _buildSection(
                      title: '✉️ Nous contacter',
                      content:
                          'Une suggestion, une mise à jour d\'information ou un problème technique ? L\'équipe i.vak est à votre écoute :',
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xff036B54).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xff036B54).withOpacity(0.2),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.email,
                                color: Color(0xff036B54),
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'annuairevakinankaratra@gmail.com',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff036B54),
                                    fontFamily: 'Lato',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Message de fin
                    Center(
                      child: Text(
                        'Version 1.0.0\nMerci d\'utiliser i.vak !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bouton "Compris"
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff036B54),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation:
                        0, // Retrait de l'élévation pour un design plus moderne (Flat)
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lato',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    List<Widget>? children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xff036B54),
            fontFamily: 'Lato',
          ),
        ),
        const SizedBox(height: 8),
        if (content.isNotEmpty)
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
              fontFamily: 'Lato',
            ),
          ),
        if (children != null) ...children,
      ],
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: const Color(0xff036B54), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
                fontFamily: 'Lato',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({required String number, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: const Color(0xff036B54).withOpacity(0.1),
              border: Border.all(color: const Color(0xff036B54)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Color(0xff036B54),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
                fontFamily: 'Lato',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
