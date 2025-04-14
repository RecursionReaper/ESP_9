import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient with pollution-themed colors
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4A80F0),
                  const Color(0xFF4A80F0).withOpacity(0.8),
                  const Color(0xFF4A80F0).withOpacity(0.6),
                ],
              ),
            ),
          ),

          // Animated particles for visual effect
          const ParticleBackground(),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Bar with back button
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'About',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 40), // Balance the layout
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // App Logo
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.air_rounded,
                          size: 80,
                          color: const Color(0xFF4A80F0),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Name
                    const Center(
                      child: Text(
                        'Delhi AQI Prediction',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // App Version
                    Center(
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // About the Project
                    _buildSectionTitle('About the Project'),

                    const SizedBox(height: 16),

                    _buildContentCard(
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Delhi AQI Prediction is a comprehensive app designed to help citizens monitor, understand, and respond to air quality conditions in Delhi NCR. Using advanced data analytics and machine learning models, our app provides accurate predictions and personalized recommendations to help you navigate the challenges of air pollution.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Case Study
                    _buildSectionTitle('Case Study'),

                    const SizedBox(height: 16),

                    _buildContentCard(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Air Pollution in Delhi: A Growing Crisis',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A80F0),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Delhi has consistently ranked among the most polluted cities globally, with annual average PM2.5 concentrations often exceeding WHO guidelines by more than 10 times. Our research indicates that:',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildBulletPoint(
                                'Over 10,000 premature deaths annually are attributed to air pollution in Delhi'),
                            _buildBulletPoint(
                                'Winter months see AQI levels frequently crossing 400 (Hazardous)'),
                            _buildBulletPoint(
                                'Vehicular emissions, industrial pollution, and crop burning are major contributors'),
                            _buildBulletPoint(
                                'Public awareness and preparedness can reduce health impacts by up to 30%'),
                            const SizedBox(height: 16),
                            const Text(
                              'This app was developed as part of our commitment to addressing this public health crisis through technology and community empowerment.',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Video Presentation
                    _buildSectionTitle('Video Presentation'),

                    const SizedBox(height: 16),

                    _buildContentCard(
                      child: Column(
                        children: [
                          // Video thumbnail with play button
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              image: const DecorationImage(
                                image: NetworkImage(
                                    'https://i.imgur.com/UYVtcCN.jpg'),
                                fit: BoxFit.cover,
                              ),
                              color: Colors.grey[300],
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.play_arrow,
                                  size: 50,
                                  color: const Color(0xFF4A80F0),
                                ),
                              ),
                            ),
                          ),

                          // Video title and action
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Delhi AQI Prediction - Project Overview',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '5:37 minutes',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // In a real app, this would launch the video link
                                    _launchURL('https://youtu.be/example');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A80F0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Watch'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Team Vision
                    _buildSectionTitle('Our Vision'),

                    const SizedBox(height: 16),

                    _buildContentCard(
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'We envision a future where technology empowers individuals to make informed decisions about their health and environment. By combining accurate data with actionable insights, we aim to contribute to broader efforts in combating air pollution and its effects on public health. Our goal is to expand this solution to other pollution-affected cities and continue refining our prediction models to help create healthier communities.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Creator Signature Section
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Profile avatar container
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF4A80F0),
                                        const Color(0xFF7AA5F2),
                                      ],
                                    ),
                                  ),
                                  child: Image(image: AssetImage("assets/kartik.jpeg"))
                                ),
                          
                                const SizedBox(height: 20),
                          
                                // Your Name with elegant styling
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF4A80F0),
                                        const Color(0xFF7AA5F2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Text(
                                    'Kartik Bulusu',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                          
                                const SizedBox(height: 12),
                          
                                // Your titles with elegant styling
                                const Text(
                                  'Developer • Designer • Data Scientist • ML Enthusiast',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                          
                                const SizedBox(height: 24),
                          
                                // Social links
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildSocialButton(
                                        Icons.link,
                                        () =>
                                            _launchURL('https://yourwebsite.com')),
                                    _buildSocialButton(
                                        Icons.code,
                                        () => _launchURL(
                                            'https://github.com/yourusername')),
                                    _buildSocialButton(
                                        Icons.email,
                                        () => _launchURL(
                                            'mailto:your.email@example.com')),
                                    _buildSocialButton(
                                        Icons.article,
                                        () => _launchURL(
                                            'https://medium.com/@yourusername')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20,),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Profile avatar container
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF4A80F0),
                                        const Color(0xFF7AA5F2),
                                      ],
                                    ),
                                  ),
                                  child: Image(image: AssetImage("assets/aniket.jpeg"))
                                ),
                          
                                const SizedBox(height: 20),
                          
                                // Your Name with elegant styling
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF4A80F0),
                                        const Color(0xFF7AA5F2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Text(
                                    'Aniket Desai',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                          
                                const SizedBox(height: 12),
                          
                                // Your titles with elegant styling
                                const Text(
                                  'Developer • Embedded Engineer • Data Scientist • ML Enthusiast',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                          
                                const SizedBox(height: 24),
                          
                                // Social links
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildSocialButton(
                                        Icons.link,
                                        () =>
                                            _launchURL('https://yourwebsite.com')),
                                    _buildSocialButton(
                                        Icons.code,
                                        () => _launchURL(
                                            'https://github.com/yourusername')),
                                    _buildSocialButton(
                                        Icons.email,
                                        () => _launchURL(
                                            'mailto:your.email@example.com')),
                                    _buildSocialButton(
                                        Icons.article,
                                        () => _launchURL(
                                            'https://medium.com/@yourusername')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Copyright and final notes
                    Center(
                      child: Text(
                        '© ${DateTime.now().year} Delhi AQI Prediction. All rights reserved.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContentCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF4A80F0),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF4A80F0)),
        onPressed: onTap,
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// Animated Particle Background for visual effect
class ParticleBackground extends StatefulWidget {
  const ParticleBackground({Key? key}) : super(key: key);

  @override
  _ParticleBackgroundState createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistent pattern

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + animationValue * 100) %
          size.height;
      final opacity = random.nextDouble() * 0.6 + 0.1;
      final radius = random.nextDouble() * 3 + 1;

      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
