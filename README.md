
# Portfolio Explorer – Rapport technique  
*Développement Mobile Flutter – 2ᵉ année Cycle Ingénieur Génie Informatique*  
**Abdel-hamid Mahamat LOUKI** – Encadré par M. Habib AYAD – *Janvier 2026*

---

## Résumé
Application **Flutter 100 % client** présentant un portfolio interactif avec :
- Barre de navigation animée (courbe Bézier)
- Polices personnalisées et thème clair / sombre dynamique
- Consommation directe d’API publiques (News, Photos, Recettes)
- Cache local & favoris persistés via `SharedPreferences`

---

## 1. Objectifs pédagogiques
- Maîtriser le widget-tree et les animations explicites (`CurvedAnimation`)
- Consommer des API REST sans serveur intermédiaire
- Respecter une architecture modulaire testable (SOLID)
- Publier un rapport technique complet sous forme open-source

---

## 2. Architecture

```
lib/
├── models/        → Article, Photo, Recipe, Project
├── services/      → NewsService, PhotosService, ThemeService, Cache
├── widgets/       → CurvedAnimationBar, AnimatedProfileCard, NewsCard...
├── screens/       → Home, News, Gallery, Recipes, Favorites
└── utils/         → themes.dart, api_keys.dart, constants.dart
```

---

## 3. Choix techniques
| Élément              | Technologie / Package                                  |
|----------------------|--------------------------------------------------------|
| SDK                  | Flutter 3.24 – Dart 3.5                                |
| State-management     | Provider (léger, testable)                             |
| Animations           | `CurvedAnimation` + `AnimationController`              |
| Polices              | `GoogleFonts` (Roboto clair, Poppins sombre)           |
| HTTP                 | `http` + `dio` (retry & cache)                         |
| Persistance          | `SharedPreferences`                                    |
| API                  | NewsAPI, Unsplash, Spoonacular (clés côté app)         |

---

## 4. Fonctionnalités détaillées

### 4.1 Curved Animation Bar
- Dessin via `CustomPainter` (courbe Bézier cubique)
- Animation de translation & scale sur l’icône active
- Durée 600 ms, courbe `easeInOutCubic`

### 4.2 Thème & polices
- `ThemeService` notifier le changement immédiat
- Polices embarquées en fallback si hors ligne
- Tokens Material 3 (couleurs, élévation, radius)

### 4.3 Consommation API (client-only)
| Type     | Endpoint exemple (GET)                                      |
|----------|-------------------------------------------------------------|
| News     | `https://newsapi.org/v2/top-headlines?country=us&apiKey=`   |
| Photos   | `https://api.unsplash.com/photos/random?client_id=`         |
| Recipes  | `https://api.spoonacular.com/recipes/random?apiKey=`        |
Cache 5 min + timestamp ; message si quota dépassé.

---

## 5. Captures d’écran
 
*Gauche : thème clair – Droite : thème sombre*

| Clair | Sombre |
|-------|--------|
| ![1](screenshots/screen%20(1).jpg) | ![4](screenshots/screen%20(4).jpg) |
| ![3](screenshots/screen%20(3).jpg) | ![2](screenshots/screen%20(2).jpg) |
| ![5](screenshots/screen%20(5).jpg) | ![8](screenshots/screen%20(8).jpg) |
| ![9](screenshots/screen%20(9).jpg) | ![6](screenshots/screen%20(6).jpg) |
| ![7](screenshots/screen%20(7).jpg) | ![10](screenshots/screen%20(10).jpg) |
| ![11](screenshots/screen%20(11).jpg) | ![12](screenshots/screen%20(12).jpg) |

---

## 6. Difficultés rencontrées & solutions
| Problème | Solution |
|----------|----------|
| Overflow horizontal dans `ProjectCard` | Remplacé `Row` par `ListView.builder` |
| Erreur CORS sur NewsAPI | Passage en **HTTPS** + headers `Accept: application/json` |
| Image non chargée hors ligne | Ajout d’un `errorBuilder` avec icône par défaut |
| Quota API dépassé | Cache JSON + message user “Quota épuisé” |

---

## 7. Tests & qualité
- Tests unitaires sur `NewsService` (mock `http.Client`)
- Coverage : `flutter test --coverage > 80 %`
- `analysis_options.yaml` : pedantic + règles Flutter team

---

## 8. Perspectives
- Internationalisation (`flutter_localizations`)
- Tests d’intégration (Appium / flutter_driver)
- Publication F-Droid & Google Play
- CI/CD via GitHub Actions (tests + build apk)

---

## 9. Conclusion
Portfolio Explorer prouve qu’un **client Flutter pur** peut offrir une UX riche en exploitant simplement des API publiques, tout en restant maintenable et testable. Le code est open-source sous licence MIT :  


