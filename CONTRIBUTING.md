# Contribuer à WeatherPulse

## Workflow Git

1. **Jamais de commit direct sur `main`** — la branche est protégée.
2. Crée ta branche à partir de `main` :
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/nom-de-la-feature
   ```
3. Commits clairs et fréquents :
   ```bash
   git commit -m "feat(weather): ajoute le repository OpenWeather"
   ```
4. Pousse ta branche :
   ```bash
   git push origin feature/nom-de-la-feature
   ```
5. Ouvre une **Pull Request** vers `main` sur GitHub.
6. Attends que la **CI passe** (✅ vert) et qu'**au moins 1 review** soit faite.
7. Le Chef de Groupe merge après validation.

## Convention de nommage des branches

- `feature/xxx` — nouvelle fonctionnalité
- `fix/xxx` — correction de bug
- `docs/xxx` — documentation

## Convention de commit

`type(scope): description`

Types : `feat`, `fix`, `docs`, `test`, `refactor`, `chore`

## Règles de code

- Respecter les couches Clean Architecture (`domain` ne dépend jamais de `data` ou `presentation`).
- Chaque nouvelle fonctionnalité côté logique métier doit avoir un test unitaire minimal.
- Lancer `flutter analyze` avant de pousser.
