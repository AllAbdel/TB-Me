// ===== lib/pages/informations_page.dart =====
import 'package:flutter/material.dart';
import '../providers/language_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/credits_widget.dart';

class InformationsPage extends StatefulWidget {
  const InformationsPage({super.key});

  @override
  _InformationsPageState createState() => _InformationsPageState();
}

class _InformationsPageState extends State<InformationsPage> {
  final LanguageProvider _languageProvider = LanguageProvider();

  String _tr(String key) {
    return _languageProvider.translate(key);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _languageProvider,
      builder: (context, child) {
        return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFF8F9FA),
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // AppBar stylé
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _tr('information.title'),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1565C0), // Bleu très foncé
                        Color(0xFF1E88E5), // Bleu foncé
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Hero - Comprendre la Tuberculose
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF81D4FA), // Bleu clair
                          Color(0xFFF8F9FA),
                          Colors.white,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.coronavirus,
                                    color: Color(0xFF1565C0),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _tr('information.understanding.title'),
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _tr('information.understanding.subtitle'),
                                        style: TextStyle(
                                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Section Qu'est-ce que la tuberculose
                    _buildInfoCard(
                      icon: Icons.help_outline,
                      iconColor: Colors.blue[600]!,
                      title: _tr('information.understanding.what_is'),
                      content: _tr('information.understanding.what_is_content'),
                      gradientColors: [Colors.blue[50]!, Colors.white],
                      borderColor: Colors.blue[200]!,
                    ),

                    const SizedBox(height: 16),

                    // Section Comment se transmet
                    _buildInfoCard(
                      icon: Icons.air,
                      iconColor: Colors.red[600]!,
                      title: _tr('information.understanding.transmission'),
                      content: _tr('information.understanding.transmission_content'),
                      gradientColors: [Colors.red[50]!, Colors.white],
                      borderColor: Colors.red[200]!,
                    ),

                    const SizedBox(height: 32),

                    const SizedBox(height: 16),

                    // Section Comment survient
                    _buildInfoCard(
                      icon: Icons.psychology,
                      iconColor: Colors.purple[600]!,
                      title: _tr('information.understanding.how_occurs'),
                      content: _tr('information.understanding.how_occurs_content'),
                      gradientColors: [Colors.purple[50]!, Colors.white],
                      borderColor: Colors.purple[200]!,
                    ),

                    const SizedBox(height: 32),

                    const SizedBox(height: 32),

                    // Section Quels sont les symptômes
                    const SizedBox(height: 16),

                    _buildInfoCard(
                      icon: Icons.coronavirus_outlined,
                      iconColor: Colors.red[600]!,
                      title: _tr('information.symptoms.what_are_symptoms'),
                      content: _tr('information.symptoms.what_are_symptoms_content'),
                      gradientColors: [Colors.red[50]!, Colors.white],
                      borderColor: Colors.red[200]!,
                    ),

                    const SizedBox(height: 32),

                    // Section Comment se soigne

                    const SizedBox(height: 16),

                    _buildInfoCard(
                      icon: Icons.medication,
                      iconColor: Colors.green[600]!,
                      title: _tr('information.symptoms.how_to_treat'),
                      content: _tr('information.symptoms.how_to_treat_content'),
                      gradientColors: [Colors.green[50]!, Colors.white],
                      borderColor: Colors.green[200]!,
                      additionalContent: Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red[600], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _tr('information.symptoms.important_note'),
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Section Comment prévenir
                    _buildInfoCard(
                      icon: Icons.vaccines,
                      iconColor: Colors.teal[600]!,
                      title: _tr('information.prevention.how_to_prevent'),
                      content: _tr('information.prevention.how_to_prevent_content'),
                      gradientColors: [Colors.teal[50]!, Colors.white],
                      borderColor: Colors.teal[200]!,
                    ),

                    const SizedBox(height: 32),

                    // Section FAQ
                    _buildSectionTitle(
                      icon: Icons.quiz,
                      title: _tr('information.faq.title'),
                      color: const Color(0xFF673AB7),
                    ),

                    const SizedBox(height: 16),

                    _buildFAQItem(_tr('information.faq.q1'), _tr('information.faq.a1')),
                    _buildFAQItem(_tr('information.faq.q2'), _tr('information.faq.a2')),
                    _buildFAQItem(_tr('information.faq.q3'), _tr('information.faq.a3')),
                    _buildFAQItem(_tr('information.faq.q4'), _tr('information.faq.a4')),

                    const SizedBox(height: 32),

                    // Section Liens Utiles
                    _buildSectionTitle(
                      icon: Icons.link,
                      title: _tr('information.links.title'),
                      color: const Color(0xFF2196F3),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildLinkItem(
                            'OMS - Organisation Mondiale de la Santé',
                            'Fiche d\'information sur la tuberculose',
                            'https://www.who.int/fr/news-room/fact-sheets/detail/tuberculosis',
                            Icons.public,
                            Colors.blue[600]!,
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          _buildLinkItem(
                            'Ministère de la Santé - France',
                            'La tuberculose : informations officielles',
                            'https://sante.gouv.fr/soins-et-maladies/maladies/maladies-et-infections-respiratoires/tuberculose/article/la-tuberculose',
                            Icons.account_balance,
                            Colors.indigo[600]!,
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          _buildLinkItem(
                            'Lutte contre la tuberculose',
                            'Stratégies et actions en France',
                            'https://sante.gouv.fr/soins-et-maladies/maladies/maladies-et-infections-respiratoires/tuberculose/article/la-lutte-contre-la-tuberculose-en-france',
                            Icons.shield,
                            Colors.green[600]!,
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          _buildLinkItem(
                            'Réfugiés.info',
                            'Information pour les réfugiés',
                            'https://refugies.info/dispositif/67220095683e602dfb9c6eb7',
                            Icons.help_center,
                            Colors.orange[600]!,
                          ),
                        ],
                      ),
                    ),
                    const CreditsWidget(),
                    const SizedBox(height: 20),
                    const SizedBox(height: 100), // Espace pour la navigation

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  Widget _buildSectionTitle({
  required IconData icon,
  required String title,
  required Color color,
  double fontSize = 22, // Valeur par défaut
}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      const SizedBox(width: 12),
      Text(
        title,
        style: TextStyle(
          fontSize: fontSize, // Utilise la valeur passée ou 22 par défaut
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2E3A59),
        ),
      ),
    ],
  );
}


  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required List<Color> gradientColors,
    required Color borderColor,
    Widget? additionalContent,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF455A64),
                height: 1.5,
              ),
            ),
            if (additionalContent != null) additionalContent,
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristic(String text, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF455A64),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptom(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.red[600], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF455A64),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF2E3A59),
          ),
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF455A64),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  // ouvrir les liens dans le navigateur
  Widget _buildLinkItem(String title, String description, String url, IconData icon, Color color) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color(0xFF2E3A59),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF455A64),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            url,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[600],
              decoration: TextDecoration.underline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Icon(Icons.open_in_new, color: color, size: 20),
      onTap: () async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text(_tr('messages.link_open_error').replaceAll('{url}', url)),
            ),
          );
        }
      },
    );
  }
}