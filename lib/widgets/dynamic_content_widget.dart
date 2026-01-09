import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DynamicContentWidget extends StatefulWidget {
  const DynamicContentWidget({super.key});

  @override
  State<DynamicContentWidget> createState() => _DynamicContentWidgetState();
}

class _DynamicContentWidgetState extends State<DynamicContentWidget> {
  String _content = 'Chargement...';
  String _contentType = 'quote';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRandomContent();
  }

  Future<void> _loadRandomContent() async {
    setState(() => _isLoading = true);

    // Randomly choose between quote and fun fact
    final random = DateTime.now().second % 2;

    if (random == 0) {
      await _loadQuote();
    } else {
      await _loadFunFact();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _content = '"${data['content']}"\n\n— ${data['author']}';
          _contentType = 'quote';
        });
      } else {
        _loadFallbackContent();
      }
    } catch (e) {
      _loadFallbackContent();
    }
  }

  Future<void> _loadFunFact() async {
    try {
      final response = await http.get(
        Uri.parse('https://uselessfacts.jsph.pl/random.json?language=en'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _content = data['text'];
          _contentType = 'fact';
        });
      } else {
        _loadFallbackContent();
      }
    } catch (e) {
      _loadFallbackContent();
    }
  }

  void _loadFallbackContent() {
    final quotes = [
      '"Le code est de la poésie écrite par des développeurs."\n\n— Anonymous',
      '"L\'innovation fait la différence entre un leader et un suiveur."\n\n— Steve Jobs',
      '"La meilleure façon de prédire l\'avenir, c\'est de le créer."\n\n— Peter Drucker',
      '"Un bon développeur est un développeur paresseux qui automatise tout."\n\n— Anonymous',
    ];

    final randomIndex = DateTime.now().second % quotes.length;
    setState(() {
      _content = quotes[randomIndex];
      _contentType = 'quote';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _contentType == 'quote' ? Icons.format_quote : Icons.lightbulb,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _contentType == 'quote' ? 'Citation du jour' : 'Saviez-vous que ?',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadRandomContent,
                  tooltip: 'Nouveau contenu',
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _content,
                  key: ValueKey(_content),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
