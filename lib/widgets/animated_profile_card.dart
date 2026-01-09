import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AnimatedProfileCard extends StatelessWidget {
  final double scrollOffset;

  const AnimatedProfileCard({super.key, required this.scrollOffset});

  // 1. Fonction pour ouvrir le lien
  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Impossible de lancer $urlString';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: Impossible d\'ouvrir le lien $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final scale = 1.0 - (scrollOffset * 0.0005).clamp(0.0, 0.2);
    final borderRadius = BorderRadius.circular(
      50 - (scrollOffset * 0.05).clamp(0.0, 30.0),
    );

    return Center(
      child: Transform.scale(
        scale: scale,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 2. Image de profil (Avec gestion d'erreur visuelle)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  // On utilise ClipOval + Image.asset pour mieux gérer l'affichage
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/profile_image.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Affiche une icône si l'image ne charge pas
                        return Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.person, size: 60, color: theme.colorScheme.onSurface),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  'Abdel-hamid M. LOUKI',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith( // Taille ajustée
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Elève ingénieur informatique',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Liens sociaux corrigés
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialIcon(context, Icons.code, 'GitHub', 'https://github.com/dirdaymi'),
                    const SizedBox(width: 16),
                    _buildSocialIcon(context, Icons.work, 'LinkedIn', 'https://www.linkedin.com/in/amlouki'),
                    const SizedBox(width: 16),
                    _buildSocialIcon(context, Icons.web, 'Linktree', 'https://tr.ee/396zU2'),
                  ],
                ),
                const SizedBox(height: 20),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('2e', 'Année Cycle Ingénieur'),
                    _buildStatItem('5+', 'Projets'),
                    _buildStatItem('80%', 'Succès'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 4. Widget corrigé pour accepter l'URL et gérer le clic
  Widget _buildSocialIcon(BuildContext context, IconData icon, String tooltip, String url) {
    return Material( // Nécessaire pour l'effet d'onde (InkWell)
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchURL(context, url), // Action au clic
        borderRadius: BorderRadius.circular(50),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6366F1),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}