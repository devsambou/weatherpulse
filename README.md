# WeatherPulse - Groupe 16 🌤️

**FlutterFire Summer Camp 2026** | Catégorie : Utilitaires & Outils Techniques (Dart & Native Focus)

## 🎯 Objectif

Application météo multi-villes avec OpenWeather API, GPS (Device Location), responsive design, et en bonus un cache local des prévisions.

## 👥 Équipe

- **Sambou TOUNKARA** — Chef de Groupe
- Membre 2 —
- Membre 3 —
- Membre 4 —
- Membre 5 —
- Membre 6 —

## 📅 Deadline

Mercredi **16 septembre 2026**

## 🏗️ Architecture

Clean Architecture, organisée par feature :

```
lib/
├── core/            # Constantes, erreurs, utilitaires partagés
└── features/
    └── weather/
        ├── domain/        # Entities, Repositories (contrats), Use Cases
        ├── data/           # Models, Datasources (remote/local), Repositories (impl)
        └── presentation/   # Pages, Widgets, ViewModels
```

## 🚀 Quick Start

```bash
git clone https://github.com/TON_USERNAME/NOM_PROJET.git
cd nom_projet
flutter pub get
flutter run --dart-define=OPENWEATHER_API_KEY=ta_cle_api
```

## ✅ CI/CD

Chaque push et chaque Pull Request déclenchent automatiquement (`.github/workflows/flutter-ci.yml`) :

- `dart format` (formatage)
- `flutter analyze` (lint)
- `flutter test` (tests unitaires)
- `flutter build apk --debug` (vérification de compilation)

Une PR ne peut être mergée sur `main` que si la CI passe (voir protection de branche).

## 📚 Ressources

- [OpenWeather API Docs](https://openweathermap.org/api)
- [Geolocator Package](https://pub.dev/packages/geolocator)
- [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)

## 📝 Contributing

Voir [CONTRIBUTING.md](CONTRIBUTING.md).
