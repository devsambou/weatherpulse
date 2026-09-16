# 🚀 WeatherPulse

**WeatherPulse** est une application météo multi-villes développée en Flutter dans le cadre du **FlutterFire Summer Camp 2026**.

L'application permet de :

- consulter la météo actuelle de plusieurs villes ;
- détecter automatiquement la position de l'utilisateur via GPS ;
- afficher une interface responsive sur mobile et tablette ;
- consulter les prévisions horaires et quotidiennes (5 jours) ;
- sauvegarder localement les préférences et les données (cache hors-ligne via Hive) ;
- gérer une liste de villes favorites ;
- basculer entre thème clair, sombre et système ;
- utiliser une interface glassmorphism adaptée aux conditions météo.

---

## 🛠️ Stack Technique

| Couche | Technologie |
|---|---|
| Framework | Flutter 3.x + Dart 3.x |
| API météo | [OpenWeatherMap](https://openweathermap.org/api) (données/2.5) |
| State management | Riverpod (`flutter_riverpod ^3.x`) |
| Injection de dépendances | `get_it` |
| Cache local & persistance | Hive (`hive`, `hive_flutter`) |
| Réseau | `http` |
| Géolocalisation | `geolocator` + `geocoding` |
| Gestion fonctionnelle | `dartz` (Either<Failure, Success>) |
| Variables d'env | `flutter_dotenv` |
| Firebase (intégré) | `firebase_core`, `cloud_firestore` |
| Architecture | **Clean Architecture** (Domain / Data / Presentation) |

---

## 📅 Calendrier

- **Début** : 2 septembre 2026
- **Fin prévue** : 16 septembre 2026

---

## 👥 Équipe

| Rôle | Nom |
|---|---|
| 👑 Chef d'équipe | **Sambou Tounkara** |
| Membre | Hilary DIALLO |
| Membre | Gaïus KOUDOUGOU |

## 🎓 Mentor

**David BONGOUADE**

---

## 🏗️ Architecture

Clean Architecture organisée par feature :

```
lib/
├── core/
│   ├── constants/         # ApiConstants, CacheConstants, FavoritesConstants, SettingsConstants
│   ├── errors/            # Exceptions & Failures typés
│   ├── location/          # Service de géolocalisation (GeolocatorLocationService)
│   ├── navigation/        # AppShell (NavigationBar 3 onglets)
│   ├── theme/             # AppTheme, WeatherPalette, GlassStyles
│   └── utils/             # FrDate, WeatherVisuals
│
├── features/
│   ├── settings/
│   │   ├── data/          # SettingsLocalDataSource, SettingsRepositoryImpl
│   │   ├── domain/        # SettingsRepository (contrat)
│   │   └── presentation/  # SettingsPage, SettingsProviders, SettingsViewModel
│   │
│   └── weather/
│       ├── data/
│       │   ├── datasources/   # WeatherRemoteDataSource, WeatherLocalDataSource, FavoritesLocalDataSource
│       │   ├── models/        # WeatherModel, ForecastModel, ForecastHourModel, FavoriteCityModel
│       │   └── repositories/  # WeatherRepositoryImpl, FavoritesRepositoryImpl
│       ├── domain/
│       │   ├── entities/      # Weather, ForecastDay, ForecastHour, FavoriteCity
│       │   ├── repositories/  # WeatherRepository, FavoritesRepository (contrats)
│       │   └── usecases/      # GetWeather, GetForecast, AddFavorite, RemoveFavorite, …
│       └── presentation/
│           ├── pages/         # HomePage, FavoritesPage
│           ├── viewmodels/    # WeatherViewModel, ForecastViewModel, FavoritesViewModel, …
│           └── widgets/       # MainWeatherCard, ForecastToggle, ForecastHourlySection, …
```

---

## 🚀 Installation & Lancement

### 1. Cloner le dépôt

```bash
git clone https://github.com/devsambou/weatherpulse.git
cd weatherpulse
```

### 2. Copier et renseigner la configuration locale

```bash
cp .env.example .env
# Éditez .env et remplacez "your_openweathermap_api_key_here" par votre clé réelle
```

### 3. Installer les dépendances

```bash
flutter pub get
```

### 4. Lancer l'application

```bash
flutter run
```

---

## ⚙️ Configuration locale

Créez un fichier `.env` à la racine du projet (ne **jamais** le committer) :

```env
OPENWEATHER_API_KEY=votre_cle_openweathermap_ici
```

Un fichier [`.env.example`](.env.example) est fourni comme modèle.

La clé est chargée automatiquement au démarrage via `flutter_dotenv` :

```dart
await dotenv.load(fileName: '.env');
```

---

## ✅ Tests

### Lancer tous les tests

```bash
flutter test
```

### Lancer les tests avec couverture

```bash
flutter test --coverage
```

### Tests ciblés

```bash
# Tests des constantes API (dotenv)
flutter test test/core/constants/api_constants_test.dart

# Tests du datasource météo distant (MockClient HTTP)
flutter test test/features/weather/weather_remote_datasource_test.dart

# Tests du widget ForecastSectionView (toggle horaire/quotidien)
flutter test test/features/weather/forecast_section_test.dart
```

### Analyse statique

```bash
dart format .
flutter analyze
```

---

## 🔒 Sécurité — Protection de la clé API

> **⚠️ IMPORTANT**
>
> La clé API OpenWeatherMap **ne doit jamais être commitée** dans le dépôt Git.

- Le fichier `.env` est listé dans `.gitignore`.
- Utilisez **toujours** `.env.example` comme modèle (sans valeur réelle).
- En CI/CD (GitHub Actions), la clé est simulée via une copie de `.env.example` ou un secret GitHub Actions.
- Dans les tests unitaires, `dotenv.testLoad(...)` est utilisé avec une valeur fictive (`TEST_OPENWEATHER_API_KEY`) sans aucune clé réelle.

---

## ♻️ CI/CD

Chaque push et chaque Pull Request déclenchent automatiquement [`.github/workflows/flutter-ci.yml`](.github/workflows/flutter-ci.yml) :

1. `dart format --output=none --set-exit-if-changed .` — Formatage du code
2. `flutter analyze --no-fatal-infos` — Analyse statique (lint)
3. `flutter test --coverage` — Suite de tests unitaires et widget tests
4. `flutter build apk --debug` — Vérification de compilation

Une PR ne peut être mergée sur `main` que si la CI passe.

---

## 📚 Ressources

- [OpenWeatherMap API Docs](https://openweathermap.org/api)
- [Geolocator Package](https://pub.dev/packages/geolocator)
- [Flutter Riverpod](https://pub.dev/packages/flutter_riverpod)
- [Hive Package](https://pub.dev/packages/hive_flutter)
- [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)

---

## 📝 Contribuer

Voir [CONTRIBUTING.md](CONTRIBUTING.md).
