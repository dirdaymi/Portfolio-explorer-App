import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Import du package
import 'package:google_fonts/google_fonts.dart'; // Import des fonts

import 'screens/home_screen.dart';
import 'screens/news_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/food_screen.dart';
import 'screens/favorites_screen.dart';
import 'services/favorites_service.dart';
import 'services/theme_service.dart';
import 'utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Portfolio Explorer',
          debugShowCheckedModeBanner: false,

          // Configuration du thème avec Google Fonts
          theme: AppTheme.lightTheme.copyWith(
            textTheme: GoogleFonts.poppinsTextTheme( // Applique Poppins partout
              AppTheme.lightTheme.textTheme,
            ),
          ),
          darkTheme: AppTheme.darkTheme.copyWith(
            textTheme: GoogleFonts.poppinsTextTheme(
              AppTheme.darkTheme.textTheme,
            ),
          ),

          themeMode: themeService.themeMode,
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

  // Clé pour contrôler la barre de navigation si nécessaire
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _screens = [
    const HomeScreen(),
    const NewsScreen(),
    const GalleryScreen(),
    const FoodScreen(),
    const FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Très important pour que le fond passe derrière la barre
      body: _screens[_currentIndex],

      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        height: 60.0,

        // Configuration des couleurs
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white, // Couleur de la barre
        buttonBackgroundColor: theme.primaryColor, // Couleur du bouton actif (la boule)
        backgroundColor: Colors.transparent, // Fond transparent pour l'effet flottant

        // Vitesse de l'animation
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),

        // Liste des icônes
        items: <Widget>[
          Icon(Icons.person, size: 30, color: _getIconColor(0, isDarkMode)),
          Icon(Icons.article, size: 30, color: _getIconColor(1, isDarkMode)),
          Icon(Icons.photo, size: 30, color: _getIconColor(2, isDarkMode)),
          Icon(Icons.restaurant, size: 30, color: _getIconColor(3, isDarkMode)),
          Icon(Icons.favorite, size: 30, color: _getIconColor(4, isDarkMode)),
        ],

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // Petite aide pour changer la couleur de l'icône active (blanche dans la boule) vs inactive
  Color _getIconColor(int index, bool isDarkMode) {
    if (_currentIndex == index) {
      return Colors.white; // Icône sélectionnée (dans la boule colorée)
    }
    return isDarkMode ? Colors.white70 : Colors.black54; // Icône non sélectionnée
  }
}