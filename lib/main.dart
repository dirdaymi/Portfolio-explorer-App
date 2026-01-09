import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/news_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/food_screen.dart';
import 'screens/favorites_screen.dart';
import 'services/favorites_service.dart';
import 'services/theme_service.dart'; // Assurez-vous que ce fichier existe (créé à l'étape précédente)
import 'utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesService()),
        ChangeNotifierProvider(create: (_) => ThemeService()), // Réintégration du service de thème
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // On écoute le ThemeService pour changer dynamiquement le mode
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Portfolio Explorer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode, // Utilisation du mode dynamique
          home: const MainNavigation(),
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const NewsScreen(),
    const GalleryScreen(),
    const FoodScreen(),
    const FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody permet au contenu de passer derrière la barre de navigation
      // ce qui rend l'effet "flottant" plus joli
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildAnimatedBottomNav(),
    );
  }

  Widget _buildAnimatedBottomNav() {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Marges pour l'effet flottant
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // Couleur de fond de la barre (adaptée au thème sombre/clair)
            color: theme.scaffoldBackgroundColor == const Color(0xFF111827) // Si mode sombre
                ? const Color(0xFF1F2937)
                : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            borderRadius: BorderRadius.circular(30), // Coins très arrondis
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAnimNavItem(Icons.person_outline, Icons.person, 'Profil', 0),
              _buildAnimNavItem(Icons.article_outlined, Icons.article, 'News', 1),
              _buildAnimNavItem(Icons.photo_outlined, Icons.photo, 'Galerie', 2),
              _buildAnimNavItem(Icons.restaurant_menu, Icons.restaurant, 'Miam', 3),
              _buildAnimNavItem(Icons.favorite_border, Icons.favorite, 'Favoris', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimNavItem(IconData iconOutline, IconData iconFilled, String label, int index) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        // Petit retour haptique (vibration légère) lors du clic
        Feedback.forTap(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint, // Courbe d'animation fluide
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          // Si sélectionné : couleur primaire, sinon transparent
          color: isSelected
              ? theme.primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? iconFilled : iconOutline,
              // Si sélectionné : blanc, sinon gris
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              size: 24,
            ),
            // On affiche le texte seulement si l'onglet est sélectionné
            // AnimatedSize gère la transition de largeur
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: isSelected ? null : 0, // Largeur 0 si non sélectionné
                child: Padding(
                  padding: isSelected
                      ? const EdgeInsets.only(left: 8)
                      : EdgeInsets.zero,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}