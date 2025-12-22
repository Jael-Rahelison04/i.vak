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
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
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
              child: Center(
                child: Text(
                  'À propos de i.vak',
                  style: const TextStyle(
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
                      title: '🎯 Objectif de l\'application',
                      content:
                          'i.vak est une application conçue pour centraliser et rendre accessibles les informations sur les établissements scolaires. Elle permet aux utilisateurs de rechercher, localiser et consulter les détails des écoles, tout en offrant des outils pratiques comme l’itinéraire, l’appel direct ou le partage d’informations. Son objectif est de faciliter la communication et l’orientation des élèves, parents, enseignants et administrateurs vers les établissements scolaires.',
                    ),

                    const SizedBox(height: 24),

                    // Section Fonctionnalités
                    _buildSection(
                      title: '🚀 Fonctionnalités principales',
                      content: '',
                      children: [
                        _buildFeatureItem(
                          icon: Icons.search,
                          text:
                              'Recherche avancée : Trouvez facilement un établissement scolaire grâce à des filtres précis. Combinez ces critères pour obtenir des résultats ciblés et pertinents.',
                        ),
                        _buildFeatureItem(
                          icon: Icons.location_on,
                          text:
                              'Localisation : Visualisez votre position et les établissements scolaires sur la carte, avec itinéraires, appel ou partage des informations.',
                        ),
                        _buildFeatureItem(
                          icon: Icons.calendar_today,
                          text:
                              'Sélection d\'année : Choisissez l\'année scolaire pour accéder aux données correspondantes',
                        ),
                        _buildFeatureItem(
                          icon: Icons.info,
                          text:
                              'Détails complets : Consultez les informations sur le personnel, diplômes, sections par classe et taux de réussite.',
                        ),
                        _buildFeatureItem(
                          icon: Icons.phone,
                          text:
                              'Actions rapides : Appelez directement ou partagez les informations de l’établissement en un clic.',
                        ),
                        _buildFeatureItem(
                          icon: Icons.directions,
                          text:
                              'Itinéraires : Affichez la distance et le temps de trajet vers un établissement.',
                        ),
                        _buildFeatureItem(
                          icon: Icons.restart_alt,
                          text:
                              'Réinitialisation : Remettez à zéro vos filtres de recherche pour repartir sur une nouvelle recherche.',
                        ),
                        _buildFeatureItem(
                          icon: Icons.wifi_off,
                          text:
                              'Gestion de la connectivité : Vous pouvez toujours effectuer des recherches même sans internet, mais les cartes et la localisation ne sont disponibles qu’avec une connexion.',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section Comment utiliser
                    _buildSection(
                      title: '📱 Comment utiliser l\'application',
                      content: '',
                      children: [
                        _buildStepItem(
                          number: '1',
                          text:
                              'Utilisez l\'onglet "Rechercher" pour trouver des personnes spécifiques',
                        ),
                        _buildStepItem(
                          number: '2',
                          text:
                              'Passez à l\'onglet "Localiser" pour voir les emplacements sur la carte',
                        ),
                        _buildStepItem(
                          number: '3',
                          text:
                              'Utilisez le bouton de sélection d\'année pour changer d\'année scolaire',
                        ),
                        _buildStepItem(
                          number: '4',
                          text:
                              'Tirez vers le bas pour rafraîchir manuellement les données',
                        ),
                        _buildStepItem(
                          number: '5',
                          text:
                              'Utilisez le bouton reset pour réinitialiser vos filtres de recherche',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section Informations techniques
                    _buildSection(
                      title: '⚙️ Informations techniques',
                      content:
                          'Cette application utilise les dernières technologies Flutter pour offrir une expérience utilisateur fluide et réactive. Les données sont stockées localement pour un accès rapide et sont synchronisées avec le serveur lorsque vous êtes connecté à Internet.',
                    ),

                    const SizedBox(height: 16),

                    // Message de fin
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xff036B54).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xff036B54).withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        'Nous espérons que cette application vous sera utile dans vos démarches quotidiennes. Pour toute suggestion ou problème technique, contactez le support informatique.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff036B54),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
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
                    elevation: 3,
                  ),
                  child: const Text(
                    'Compris',
                    style: TextStyle(
                      fontSize: 18,
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
            fontWeight: FontWeight.w600,
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
          Icon(icon, color: const Color(0xff036B54), size: 20),
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
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xff036B54),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
