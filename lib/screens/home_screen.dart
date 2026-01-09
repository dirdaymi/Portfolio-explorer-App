import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/favorites_service.dart';
import '../services/theme_service.dart'; // Import du service de thème
import '../widgets/animated_profile_card.dart';
import '../widgets/skill_chip.dart';
import '../widgets/project_card.dart';
import '../widgets/dynamic_content_widget.dart';
import 'news_screen.dart';
import 'gallery_screen.dart';
import 'food_screen.dart';
import 'favorites_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  final Map<String, int> _skills = {
    'Flutter & Dart': 95,
    'UI/UX Design': 90,
    'Cloud computing - AWS': 85,
    'RESTful APIs': 88,
    'Spring Boot': 92,
    'Angular': 87,
    'Git & GitHub': 90,
    'Agile/Scrum': 85,
  };

  final List<Map<String, dynamic>> _projects = [
    {
      'title': 'Task Management Platform',
      'description': 'INFRASTRUCTURE CLOUD DE SUPERVISION CENTRALISÉE SOUS AWS',
      'technologies': ['AWS Cloud', 'Docker', 'Zabbix'],
      'image': 'assets/images/luke-chesser-JKUTrJ4vK00-unsplash.jpg',
      'url': 'https://github.com/dirdaymi/aws-zabbix-monitoring.git',
    },
    {
      'title': 'Smart Bank',
      'description': 'Application bancaire avec integration IA',
      'technologies': ['Springs, Spring Boot', 'Angular'],
      'image': 'assets/images/ales-nesetril-ex_p4AaBxbs-unsplash.jpg',
      'url': 'https://github.com/dirdaymi/Smart-bank.git',
    },
    {
      'title': 'E-Commerce Mobile App',
      'description': 'App complète avec panier, paiement et notifications',
      'technologies': ['Java', 'Firebase', 'Stripe'],
      'image': 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400',
      'url': 'https://github.com/dirdaymi',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Portfolio Explorer',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareProfile,
            tooltip: 'Partager mon profil',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                _buildHeaderBackground(theme),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedProfileCard(scrollOffset: _scrollOffset),
                      const SizedBox(height: 32),
                      _buildAboutSection(theme),
                      const SizedBox(height: 32),
                      _buildSkillsSection(theme),
                      const SizedBox(height: 32),
                      _buildProjectsSection(theme),
                      const SizedBox(height: 32),
                      const DynamicContentWidget(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground(ThemeData theme) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'À Propos',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Elève ingénieur informatique, je suis passionné par la création d\'expériences mobiles innovantes. '
                  'Je transforme les idées en applications performantes et élégantes.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildTag('Mobile Developer', theme),
                _buildTag('UI/UX Enthusiast', theme),
                _buildTag('Open Source', theme),
                _buildTag('Web site developper', theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compétences',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            ..._skills.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SkillChip(
                skill: entry.key,
                percentage: entry.value,
                onTap: () => _showSkillDetails(context, entry.key),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Projets',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400, // Hauteur augmentée pour éviter l'overflow
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _projects.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final project = _projects[index];
                  return ProjectCard(project: project);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  // Image de profil dans le drawer
                  backgroundImage: const AssetImage('assets/images/profile_image.jpg'),
                  onBackgroundImageError: (_, __) => {},

                ),
                const SizedBox(height: 12),
                Text(
                  'Abdel-hamid M. LOUKI',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                /*Text(
                  'Elève ingénieur informatique',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),*/
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Actualités'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Galerie'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text('Recettes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favoris'),
            trailing: Consumer<FavoritesService>(
              builder: (context, service, _) => Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  service.favorites.length.toString(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
            },
          ),
          const Divider(),

          // === BOUTON DE CHANGEMENT DE THÈME ===
          Consumer<ThemeService>(
            builder: (context, themeService, _) {
              return SwitchListTile(
                title: const Text('Mode Sombre'),
                secondary: Icon(
                  themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: theme.iconTheme.color,
                ),
                value: themeService.isDarkMode,
                onChanged: (bool value) {
                  themeService.toggleTheme();
                },
                activeColor: theme.colorScheme.primary,
              );
            },
          ),
          // =====================================

          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('À Propos'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Contact'),
            onTap: () {
              Navigator.pop(context);
              _launchEmail();
            },
          ),
        ],
      ),
    );
  }

  void _showSkillDetails(BuildContext context, String skill) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(skill, style: theme.textTheme.headlineMedium),
        content: Text(
          _getSkillDescription(skill),
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Portfolio Explorer',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Abdel-hamid M. LOUKI',
      children: const [
        SizedBox(height: 20),
        Text('Application développée avec Flutter pour démontrer mes compétences en développement mobile et web.'),
      ],
    );
  }

  String _getSkillDescription(String skill) {
    final descriptions = {
      'Flutter & Dart': 'Expertise en développement cross-platform avec Flutter. Maîtrise de Dart, widgets personnalisés, et performance optimization.',
      'UI/UX Design': 'Création d\'interfaces intuitives et élégantes. Connaissance des principes de design et de l\'expérience utilisateur.',
      'Firebase': 'Intégration complète des services Firebase : Auth, Firestore, Storage, Cloud Functions, et Analytics.',
      'RESTful APIs': 'Consommation et intégration d\'APIs RESTful. Gestion des états asynchrones et erreurs.',
      'Spring Boot': 'Développement de backends robustes avec Java et Spring Boot.',
      'Angular': 'Création d\'applications web dynamiques avec le framework Angular.',
      'Git & GitHub': 'Versionnage efficace, collaboration d\'équipe, CI/CD avec GitHub Actions.',
      'Agile/Scrum': 'Travail en équipe agile. Participation aux sprints, daily standups et retrospectives.',
      'Cloud computing - AWS': 'Déploiement et gestion d\'infrastructures cloud sur Amazon Web Services.',
    };
    return descriptions[skill] ?? 'Compétence en cours de développement.';
  }

  Future<void> _shareProfile() async {
    const String profileUrl = "https://tr.ee/396zU2";
    const String message = "Découvrez le portfolio de Abdel-hamid M. LOUKI : $profileUrl";
    await Clipboard.setData(const ClipboardData(text: message));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lien du profil copié dans le presse-papier !'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'am.louki@outlook.fr',
      query: 'subject=Contact depuis Portfolio Explorer',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir l\'application email')),
        );
      }
    }
  }
}