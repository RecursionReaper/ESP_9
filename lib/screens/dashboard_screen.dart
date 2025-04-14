import 'package:aqi/utils/theme.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late AQIData _currentData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _currentData = AQIData.getCurrentData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aqiCategory = AQIUtils.getAQICategory(_currentData.aqi);
    final aqiColor = AQIUtils.getAQIColor(_currentData.aqi);
    final healthTip = AQIUtils.getHealthTip(_currentData.aqi);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delhi AQI Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refreshing AQI data...')));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          PollutionOverlay(aqiValue: _currentData.aqi),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentData.location,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Last updated: ${_formattedDateTime(_currentData.timestamp)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedWeatherIcon(
                            animationController: _animationController,
                            aqiValue: _currentData.aqi,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Current AQI: ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                              Text(
                                '${_currentData.aqi}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: aqiColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            aqiCategory,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: aqiColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 200,
                            child: AQIGauge(aqiValue: _currentData.aqi),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                 
                  HealthAlertCard(aqiValue: _currentData.aqi),

                  const SizedBox(height: 24),

                  
                  if (_currentData.details != null) ...[
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pollutant Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPollutantDetail('PM2.5',
                                '${_currentData.details!['pm2_5']} μg/m³'),
                            _buildPollutantDetail('PM10',
                                '${_currentData.details!['pm10']} μg/m³'),
                            _buildPollutantDetail('Ozone (O3)',
                                '${_currentData.details!['o3']} ppb'),
                            _buildPollutantDetail('Nitrogen Dioxide (NO2)',
                                '${_currentData.details!['no2']} ppb'),
                            _buildPollutantDetail('Sulfur Dioxide (SO2)',
                                '${_currentData.details!['so2']} ppb'),
                            _buildPollutantDetail('Carbon Monoxide (CO)',
                                '${_currentData.details!['co']} ppm'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Quick Actions
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildActionButton(
                                  context, Icons.map, 'Safe Zones'),
                              _buildActionButton(
                                  context, Icons.local_hospital, 'Hospitals'),
                              _buildActionButton(
                                  context, Icons.masks, 'Buy Masks'),
                              _buildActionButton(
                                  context, Icons.air, 'Air Purifiers'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollutantDetail(String name, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: Icon(icon, color: Theme.of(context).primaryColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening $label...')),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  String _formattedDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class AQIGauge extends StatelessWidget {
  final int aqiValue;

  const AQIGauge({Key? key, required this.aqiValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: AQIGaugePainter(aqiValue: aqiValue),
    );
  }
}

class AQIGaugePainter extends CustomPainter {
  final int aqiValue;

  AQIGaugePainter({required this.aqiValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width, size.height) * 0.8;

    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

  
    _drawColorSegment(
        canvas, center, radius, math.pi, math.pi / 6, Colors.green, 20);
    _drawColorSegment(canvas, center, radius, math.pi + math.pi / 6,
        math.pi / 6, Colors.yellow, 20);
    _drawColorSegment(canvas, center, radius, math.pi + math.pi / 3,
        math.pi / 6, Colors.orange, 20);
    _drawColorSegment(canvas, center, radius, math.pi + math.pi / 2,
        math.pi / 6, Colors.red, 20);
    _drawColorSegment(canvas, center, radius, math.pi + 2 * math.pi / 3,
        math.pi / 6, Colors.purple, 20);
    _drawColorSegment(canvas, center, radius, math.pi + 5 * math.pi / 6,
        math.pi / 6, Colors.deepPurple, 20);

    final progress = math.min(aqiValue / 500, 1.0);
    final angle = math.pi + math.pi * progress;

 
    _drawNeedle(canvas, center, radius * 0.8, angle);

  
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 20, centerPaint);

    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, 20, borderPaint);

 
    final textPainter = TextPainter(
      text: TextSpan(
        text: aqiValue.toString(),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2),
    );


    _drawCategoryLabel(canvas, center, radius * 1.1, math.pi + math.pi / 12,
        'Good', Colors.green);
    _drawCategoryLabel(canvas, center, radius * 1.1, math.pi + math.pi / 4,
        'Moderate', Colors.yellow);
    _drawCategoryLabel(canvas, center, radius * 1.1, math.pi + 5 * math.pi / 12,
        'Unhealthy\nfor Sensitive', Colors.orange);
    _drawCategoryLabel(canvas, center, radius * 1.1, math.pi + 7 * math.pi / 12,
        'Unhealthy', Colors.red);
    _drawCategoryLabel(canvas, center, radius * 1.1, math.pi + 3 * math.pi / 4,
        'Very\nUnhealthy', Colors.purple);
    _drawCategoryLabel(canvas, center, radius * 1.1,
        math.pi + 11 * math.pi / 12, 'Hazardous', Colors.deepPurple);
  }

  void _drawColorSegment(Canvas canvas, Offset center, double radius,
      double startAngle, double sweepAngle, Color color, double strokeWidth) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  void _drawNeedle(Canvas canvas, Offset center, double length, double angle) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy);
    path.lineTo(
      center.dx + length * math.cos(angle),
      center.dy + length * math.sin(angle),
    );
    path.lineTo(
      center.dx + 5 * math.cos(angle + math.pi / 2),
      center.dy + 5 * math.sin(angle + math.pi / 2),
    );
    path.lineTo(
      center.dx + 5 * math.cos(angle - math.pi / 2),
      center.dy + 5 * math.sin(angle - math.pi / 2),
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawCategoryLabel(Canvas canvas, Offset center, double radius,
      double angle, String label, Color color) {
    final x = center.dx + radius * math.cos(angle);
    final y = center.dy + radius * math.sin(angle);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: 60);
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class AnimatedWeatherIcon extends StatelessWidget {
  final AnimationController animationController;
  final int aqiValue;

  const AnimatedWeatherIcon({
    Key? key,
    required this.animationController,
    required this.aqiValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(48, 48),
          painter: _WeatherIconPainter(
            animation: animationController.value,
            aqiValue: aqiValue,
          ),
        );
      },
    );
  }
}

class _WeatherIconPainter extends CustomPainter {
  final double animation;
  final int aqiValue;

  _WeatherIconPainter({
    required this.animation,
    required this.aqiValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (aqiValue <= 100) {
     
      _drawSun(canvas, center, size.width * 0.4, animation);
    } else {
  
      _drawSmog(canvas, size, animation);
    }
  }


  void _drawSun(Canvas canvas, Offset center, double radius, double animation) {
  
    final sunPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * (0.9 + animation * 0.1), sunPaint);


    final rayPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final rayStart = Offset(
        center.dx + radius * 1.2 * math.cos(angle),
        center.dy + radius * 1.2 * math.sin(angle),
      );
      final rayEnd = Offset(
        center.dx + radius * (1.5 + animation * 0.2) * math.cos(angle),
        center.dy + radius * (1.5 + animation * 0.2) * math.sin(angle),
      );

      canvas.drawLine(rayStart, rayEnd, rayPaint);
    }
  }

  void _drawSmog(Canvas canvas, Size size, double animation) {
    final smogPaint = Paint()
      ..color = Colors.grey.withOpacity(0.7 + animation * 0.3)
      ..style = PaintingStyle.fill;

   
    final path = Path();


    path.addOval(Rect.fromCenter(
      center: Offset(size.width * 0.3, size.height * 0.4),
      width: size.width * 0.3,
      height: size.height * 0.25,
    ));


    path.addOval(Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.3),
      width: size.width * 0.4,
      height: size.height * 0.3,
    ));

    
    path.addOval(Rect.fromCenter(
      center: Offset(size.width * 0.7, size.height * 0.5),
      width: size.width * 0.3,
      height: size.height * 0.25,
    ));


    path.addOval(Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.6),
      width: size.width * 0.6,
      height: size.height * 0.3,
    ));

    canvas.drawPath(path, smogPaint);

   
    final linePaint = Paint()
      ..color = Colors.grey.shade700.withOpacity(0.3 + animation * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final y = size.height * (0.3 + i * 0.1);
      final startX = size.width * 0.2 + animation * size.width * 0.1;
      final endX = size.width * 0.8 - animation * size.width * 0.1;

      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class HealthAlertCard extends StatelessWidget {
  final int aqiValue;

  const HealthAlertCard({Key? key, required this.aqiValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final healthTip = AQIUtils.getHealthTip(aqiValue);
    final aqiColor = AQIUtils.getAQIColor(aqiValue);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: aqiColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Health Advisory',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              healthTip,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _buildHealthRecommendations(aqiValue),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRecommendations(int aqi) {
    final recommendations = <Widget>[];

    if (aqi > 100) {
      recommendations.add(_buildRecommendationItem(
        Icons.masks,
        'Wear an N95 mask when outdoors',
      ));
    }

    if (aqi > 150) {
      recommendations.add(_buildRecommendationItem(
        Icons.directions_run,
        'Avoid outdoor exercise and strenuous activities',
      ));
    }

    if (aqi > 200) {
      recommendations.add(_buildRecommendationItem(
        Icons.house,
        'Stay indoors with windows closed',
      ));
      recommendations.add(_buildRecommendationItem(
        Icons.air,
        'Use air purifiers if available',
      ));
    }

    if (aqi > 300) {
      recommendations.add(_buildRecommendationItem(
        Icons.local_hospital,
        'Seek medical attention if experiencing difficulty breathing',
      ));
    }

    if (recommendations.isEmpty) {
      recommendations.add(_buildRecommendationItem(
        Icons.nature_people,
        'Enjoy outdoor activities',
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: recommendations,
    );
  }

  Widget _buildRecommendationItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class PollutionOverlay extends StatelessWidget {
  final int aqiValue;

  const PollutionOverlay({Key? key, required this.aqiValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    if (aqiValue <= 100) {
      return Container();
    }


    final opacity = math.min((aqiValue - 100) / 400, 0.5);

    return Positioned.fill(
      child: CustomPaint(
        painter: _PollutionPainter(opacity: opacity),
      ),
    );
  }
}

class _PollutionPainter extends CustomPainter {
  final double opacity;
  final math.Random _random =
      math.Random(42);

  _PollutionPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {

    final Paint fogPaint = Paint()
      ..color = Colors.grey.withOpacity(opacity * 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fogPaint);


    final particlePaint = Paint()
      ..color = Colors.grey.shade700.withOpacity(opacity * 0.4)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 100; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final radius = _random.nextDouble() * 2 + 0.5;

      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }


    for (int i = 0; i < 3; i++) {
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey.withOpacity(0),
          Colors.grey.withOpacity(opacity * 0.2),
          Colors.grey.withOpacity(0),
        ],
        stops: [0.0, 0.5, 1.0],
      );

      final shader = gradient.createShader(
        Rect.fromLTWH(0, size.height * i / 3, size.width, size.height / 3),
      );

      final gradientPaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(0, size.height * i / 3, size.width, size.height / 3),
        gradientPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
