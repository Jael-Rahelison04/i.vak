// widget_builder_service.dart
import 'package:flutter/material.dart';
import 'package:annuaire_scolaire/services/format_service.dart';
import 'package:annuaire_scolaire/services/phone_service.dart';

class WidgetBuilderService {
  // Méthode helper pour les séparateurs
  static Widget buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade200);
  }

  // Widget pour afficher le résultat global
  static Widget buildResultWidget({
    required String niveau,
    required String resultat,
  }) {
    if (niveau.toLowerCase() == 'prescolaire' ||
        resultat.isEmpty ||
        resultat.toLowerCase() == 'indisponible') {
      return const SizedBox.shrink();
    } else {
      String libelleResultat = FormatService.getLibelleResultat(niveau);

      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 16,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: libelleResultat,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: FormatService.formatResultat(resultat)),
            ],
          ),
        ),
      );
    }
  }

  // Widget pour les items de personnel
  static Widget buildPersonnelItem({
    required String title,
    required String value,
    bool isFirst = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour les items de diplômes
  static Widget buildDiplomeItem({
    required String title,
    required String value,
    bool isFirst = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour les items de sections
  static Widget buildSectionItem({
    required String title,
    required String value,
    bool isTotal = false,
  }) {
    if (isTotal) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff036B54).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xff036B54).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xff036B54),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xff036B54),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // Widget pour les items de taux BAC
  static Widget buildTauxBacItem({
    required String title,
    required String value,
    bool isFirst = false,
  }) {
    String formattedValue = FormatService.formatTauxBac(value);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Text(
              formattedValue,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour les items de contact
  static Widget buildContactInfoItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    bool isPhone = false,
  }) {
    if (isPhone && value.isNotEmpty) {
      final phoneNumbers = PhoneService.formatPhoneNumbers(value);

      if (phoneNumbers.isEmpty) {
        return _buildSimpleContactItem(icon: icon, value: value);
      }

      return _buildMultiplePhoneNumbers(
        context: context,
        icon: icon,
        phoneNumbers: phoneNumbers,
        originalValue: value,
      );
    } else {
      return _buildSimpleContactItem(icon: icon, value: value);
    }
  }

  static Widget _buildSimpleContactItem({
    required IconData icon,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(icon, color: Colors.grey, size: 26),
        ],
      ),
    );
  }

  static Widget _buildMultiplePhoneNumbers({
    required BuildContext context,
    required IconData icon,
    required List<String> phoneNumbers,
    required String originalValue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Affichage du texte original (optionnel - peut être retiré)
          Text(
            "Contacts téléphoniques :",
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),

          // Liste des numéros formatés avec icônes d'appel
          ...phoneNumbers.asMap().entries.map((entry) {
            final index = entry.key;
            final formattedNumber = entry.value;

            return Column(
              children: [
                if (index > 0) const SizedBox(height: 8),
                _buildPhoneNumberRow(
                  context: context,
                  formattedNumber: formattedNumber,
                  originalNumber: PhoneService.extractPhoneNumbers(
                    originalValue,
                  )[index],
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  static Widget _buildPhoneNumberRow({
    required BuildContext context,
    required String formattedNumber,
    required String originalNumber,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              formattedNumber,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff036B54),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => PhoneService.makePhoneCall(
              context: context,
              phoneNumber: originalNumber,
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xff036B54),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.phone, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour le container animé (réutilisable pour toutes les sections)
  static Widget buildAnimatedSection({
    required bool isExpanded,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuart,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: isExpanded ? const EdgeInsets.all(20) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 1,
                ),
              ]
            : null,
        border: Border.all(
          color: const Color(0xff036B54).withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: isExpanded ? child : null,
    );
  }

  // Widget pour l'en-tête de section avec bouton d'expansion
  static Widget buildSectionHeader({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: const Color(0xff036B54),
          ),
          onPressed: onToggle,
        ),
      ],
    );
  }

  // Widget pour la carte hors ligne
  static Widget buildOfflineMap({
    required bool isRefreshing,
    required VoidCallback onRefresh,
  }) {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: isRefreshing
          ? const CircularProgressIndicator(color: Color(0xff036B54))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Veuillez vous connectez, s\'il vous plaît !',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    color: Color(0xff036B54),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5.0),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Color(0xff036B54),
                    size: 30,
                  ),
                  tooltip: 'Actualiser',
                  onPressed: onRefresh,
                ),
              ],
            ),
    );
  }

  // Widget pour l'effectif total (style spécial)
  static Widget buildEffectifTotal({
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff036B54).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xff036B54).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xff036B54),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xff036B54),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour les informations de base de l'établissement
  static Widget buildSchoolInfo({
    required String nomEtab,
    required String niveau,
    required String secteur,
    required String cisco,
    required String commune,
    required String fokontany,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            nomEtab,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff036B54),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${FormatService.formatNiveau(niveau)} - $secteur',
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildRichText('CISCO : ', cisco),
        const SizedBox(height: 16),
        _buildRichText('Commune : ', commune),
        const SizedBox(height: 16),
        _buildRichText('Fokontany : ', fokontany),
      ],
    );
  }

  // Méthode helper pour les textes enrichis
  static Widget _buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Lato',
          fontSize: 16,
          color: Colors.black87,
        ),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
