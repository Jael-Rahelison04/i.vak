<img width="720" height="1600" alt="Screenshot_20261103-153456" src="https://github.com/user-attachments/assets/a32b14f1-c5dd-4b99-8034-b92fca655ee3" /># i-vak

**i-vak** (anciennement *Annuaire-Scolaire*) est une application mobile développée avec Flutter. Elle permet de [décrire en une phrase : trouver et consulter les établissements scolaires de Madagascar].

## Fonctionnalités

- Recherche d'établissements par [nom, localité, type...]
- Affichage des détails d'un établissement (coordonnées, contact, etc.)
- Localisation et calcul d'itinéraire vers un établissement
- Appel direct et partage des informations d'un établissement
- Sélection de l'année scolaire
- Gestion de l'état de connexion (fonctionnement hors ligne : [oui / partiel / non])
- Import des données depuis un fichier Excel

## Technologies

- [Flutter](https://flutter.dev) / Dart
- Plateforme principale : Android ([et iOS, si testé])
- Données : [fichier Excel / API / base locale]

## Installation

Prérequis : Flutter SDK installé ([guide officiel](https://docs.flutter.dev/get-started/install)).

```bash
git clone https://github.com/Jael-Rahelison04/i.vak.git
cd i.vak
flutter pub get
flutter run
```

## Structure du projet

```
lib/
├── main.dart          # Point d'entrée
├── managers/          # Gestion de l'état et de la navigation
├── model/             # Modèles de données (Etablissement)
├── pages/             # Écrans de l'application
├── services/          # Localisation, itinéraire, appel, partage...
├── utils/             # Utilitaires (lecture Excel)
└── widgets/           # Composants réutilisables
```

## Captures d'écran

<p>
  <img width="220" alt="Acueil" src="https://github.com/user-attachments/assets/2d5f0652-cfe4-45bb-ac21-a205060c5c05" />
  <img width="220" alt="Carte" src="https://github.com/user-attachments/assets/1324648d-ab4e-4101-8dc6-66d483580cda" />
  <img width="220" alt="Itineraire" src="https://github.com/user-attachments/assets/93b21519-a539-4b8f-8b85-6916d6afb03b" />
  <img width="220" alt="Navigation" src="https://github.com/user-attachments/assets/de9a42e7-bc20-4496-a4f9-138cd457a7bb" />
  <img width="220" alt="Detail" src="https://github.com/user-attachments/assets/9670c6a9-bef4-4cda-b317-79bfa45d0608" />
</p>

## Auteur

Développé par RAHELISON Jael ([@Jael-Rahelison04](https://github.com/Jael-Rahelison04)).
