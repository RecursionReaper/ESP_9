import 'package:flutter/material.dart';
import 'dart:ui';

class HealthAdvisory extends StatefulWidget {
  final int currentAQI;
  
  const HealthAdvisory({
    Key? key, 
    this.currentAQI = 175, // Default value for demonstration
  }) : super(key: key);

  @override
  _HealthAdvisoryState createState() => _HealthAdvisoryState();
}

class _HealthAdvisoryState extends State<HealthAdvisory> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _aqiCategory;
  late Color _aqiColor;
  late List<HealthTip> _healthTips;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updateAQIInfo();
  }
  
  void _updateAQIInfo() {
    // Determine AQI category and color based on AQI value
    if (widget.currentAQI <= 50) {
      _aqiCategory = "Good";
      _aqiColor = const Color(0xFF00E400);
      _healthTips = _goodAQITips;
    } else if (widget.currentAQI <= 100) {
      _aqiCategory = "Moderate";
      _aqiColor = const Color(0xFFFFFF00);
      _healthTips = _moderateAQITips;
    } else if (widget.currentAQI <= 150) {
      _aqiCategory = "Unhealthy for Sensitive Groups";
      _aqiColor = const Color(0xFFFF7E00);
      _healthTips = _unhealthySensitiveTips;
    } else if (widget.currentAQI <= 200) {
      _aqiCategory = "Unhealthy";
      _aqiColor = const Color(0xFFFF0000);
      _healthTips = _unhealthyTips;
    } else if (widget.currentAQI <= 300) {
      _aqiCategory = "Very Unhealthy";
      _aqiColor = const Color(0xFF99004C);
      _healthTips = _veryUnhealthyTips;
    } else {
      _aqiCategory = "Hazardous";
      _aqiColor = const Color(0xFF7E0023);
      _healthTips = _hazardousTips;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Smog Visualization Background
          SmogVisualization(
            aqiValue: widget.currentAQI,
            aqiColor: _aqiColor,
          ),
          
          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar with Back Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Health Advisory',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline, color: Colors.white),
                          onPressed: () {
                            // Show AQI info dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('About AQI Categories'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildAQIInfoItem("Good (0-50)", "Air quality is satisfactory, and air pollution poses little or no risk.", const Color(0xFF00E400)),
                                      _buildAQIInfoItem("Moderate (51-100)", "Air quality is acceptable. However, there may be a risk for some people.", const Color(0xFFFFFF00)),
                                      _buildAQIInfoItem("Unhealthy for Sensitive Groups (101-150)", "Members of sensitive groups may experience health effects.", const Color(0xFFFF7E00)),
                                      _buildAQIInfoItem("Unhealthy (151-200)", "Everyone may begin to experience health effects.", const Color(0xFFFF0000)),
                                      _buildAQIInfoItem("Very Unhealthy (201-300)", "Health warnings of emergency conditions.", const Color(0xFF99004C)),
                                      _buildAQIInfoItem("Hazardous (301+)", "Health alert: everyone may experience more serious health effects.", const Color(0xFF7E0023)),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Current AQI Display
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildAQIDisplay(),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Tab Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white,
                      ),
                      labelColor: _aqiColor,
                      unselectedLabelColor: Colors.white,
                      tabs: const [
                        Tab(text: 'Health Tips'),
                        Tab(text: 'Precautions'),
                        Tab(text: 'Hospitals'),
                      ],
                    ),
                  ),
                  
                  // Tab Bar View
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Health Tips Tab
                        _buildHealthTipsTab(),
                        
                        // Precautions Tab
                        _buildPrecautionsTab(),
                        
                        // Hospitals Tab
                        _buildHospitalsTab(),
                      ],
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
  
  Widget _buildAQIInfoItem(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Text(description),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAQIDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _aqiColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _aqiColor.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.currentAQI.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _aqiCategory,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _getCategoryDescription(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getCategoryDescription() {
    switch (_aqiCategory) {
      case "Good":
        return "Air quality is considered satisfactory, and air pollution poses little or no risk.";
      case "Moderate":
        return "Air quality is acceptable; however, some pollutants may be a concern for a small number of people.";
      case "Unhealthy for Sensitive Groups":
        return "Members of sensitive groups may experience health effects. The general public is less likely to be affected.";
      case "Unhealthy":
        return "Everyone may begin to experience health effects; members of sensitive groups may experience more serious health effects.";
      case "Very Unhealthy":
        return "Health warnings of emergency conditions. The entire population is more likely to be affected.";
      case "Hazardous":
        return "Health alert: everyone may experience more serious health effects.";
      default:
        return "";
    }
  }
  
  Widget _buildHealthTipsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _healthTips.length,
      itemBuilder: (context, index) {
        final tip = _healthTips[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
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
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: Icon(
              tip.icon,
              color: _aqiColor,
              size: 28,
            ),
            title: Text(
              tip.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(tip.description),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPrecautionsTab() {
    List<Map<String, dynamic>> precautions = [
      {
        'title': 'Use N95 Masks',
        'description': 'Wear N95 or N99 masks when going outside to reduce exposure to pollutants.',
        'icon': Icons.masks,
      },
      {
        'title': 'Use Air Purifiers',
        'description': 'Keep indoor air clean with air purifiers that have HEPA filters.',
        'icon': Icons.air,
      },
      {
        'title': 'Keep Windows Closed',
        'description': 'Seal windows and doors to prevent outdoor pollutants from entering your home.',
        'icon': Icons.window,
      },
      {
        'title': 'Stay Hydrated',
        'description': 'Drink plenty of water to help your body remove toxins from airborne pollutants.',
        'icon': Icons.water_drop,
      },
      {
        'title': 'Avoid Outdoor Exercise',
        'description': 'Exercise indoors, especially during peak pollution hours.',
        'icon': Icons.fitness_center,
      },
      {
        'title': 'Use Public Transport',
        'description': 'Reduce your carbon footprint by using public transportation when possible.',
        'icon': Icons.directions_bus,
      },
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: precautions.length,
      itemBuilder: (context, index) {
        final precaution = precautions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
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
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: Icon(
              precaution['icon'],
              color: _aqiColor,
              size: 28,
            ),
            title: Text(
              precaution['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(precaution['description']),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildHospitalsTab() {
    // Sample hospitals data
    List<Map<String, dynamic>> hospitals = [
      {
        'name': 'AIIMS Delhi',
        'address': 'Sri Aurobindo Marg, Ansari Nagar, New Delhi',
        'distance': '3.5 km',
        'type': 'Government',
        'contact': '+91 11 2658 8500',
      },
      {
        'name': 'Safdarjung Hospital',
        'address': 'Ansari Nagar West, New Delhi',
        'distance': '4.2 km',
        'type': 'Government',
        'contact': '+91 11 2673 0000',
      },
      {
        'name': 'Apollo Hospital',
        'address': 'Sarita Vihar, Delhi Mathura Road, New Delhi',
        'distance': '8.7 km',
        'type': 'Private',
        'contact': '+91 11 2687 1101',
      },
      {
        'name': 'Max Super Speciality Hospital',
        'address': 'Press Enclave Road, Saket, New Delhi',
        'distance': '6.1 km',
        'type': 'Private',
        'contact': '+91 11 2651 5050',
      },
      {
        'name': 'Fortis Hospital',
        'address': 'Okhla road, Sukhdev Vihar, New Delhi',
        'distance': '5.8 km',
        'type': 'Private',
        'contact': '+91 11 4277 6222',
      },
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: hospitals.length,
      itemBuilder: (context, index) {
        final hospital = hospitals[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
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
            tilePadding: const EdgeInsets.all(15),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            leading: const Icon(
              Icons.local_hospital,
              color: Colors.redAccent,
              size: 28,
            ),
            title: Text(
              hospital['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text('${hospital['distance']} • ${hospital['type']}'),
            children: [
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('Address'),
                subtitle: Text(hospital['address']),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Contact'),
                subtitle: Text(hospital['contact']),
                trailing: IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () {
                    // In a real app, implement phone call functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${hospital['name']}...')),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.directions),
                    label: const Text('Get Directions'),
                    onPressed: () {
                      // In a real app, implement map directions
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Getting directions to ${hospital['name']}...')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Smog Visualization Widget
class SmogVisualization extends StatefulWidget {
  final int aqiValue;
  final Color aqiColor;
  
  const SmogVisualization({
    Key? key,
    required this.aqiValue,
    required this.aqiColor,
  }) : super(key: key);

  @override
  _SmogVisualizationState createState() => _SmogVisualizationState();
}

class _SmogVisualizationState extends State<SmogVisualization> with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Determine smog intensity based on AQI value
    double smogIntensity = widget.aqiValue / 500.0; // Scale from 0.0 to 1.0
    smogIntensity = smogIntensity.clamp(0.1, 0.95);
    
    return Stack(
      children: [
        // Background Image (Delhi Skyline)
        Image.network(
          'https://i.imgur.com/LBMOnNR.jpg', // Placeholder image of Delhi skyline
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        
        // Smog Effect Layer
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 3.0 + (_controller.value * 2.0) * smogIntensity,
                sigmaY: 3.0 + (_controller.value * 2.0) * smogIntensity,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.aqiColor.withOpacity(0.7 * smogIntensity),
                      widget.aqiColor.withOpacity(0.5 * smogIntensity),
                      widget.aqiColor.withOpacity(0.3 * smogIntensity),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // Floating Particles Effect (more visible in worse AQI)
        if (widget.aqiValue > 100)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: SmogParticlesPainter(
                  animationValue: _controller.value,
                  particleColor: widget.aqiColor,
                  particleDensity: smogIntensity * 100,
                ),
                size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
              );
            },
          ),
      ],
    );
  }
}

// Custom Painter for Smog Particles
class SmogParticlesPainter extends CustomPainter {
  final double animationValue;
  final Color particleColor;
  final double particleDensity;
  
  SmogParticlesPainter({
    required this.animationValue,
    required this.particleColor,
    required this.particleDensity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final random = DateTime.now().millisecondsSinceEpoch;
    final particleCount = particleDensity.toInt();
    
    for (int i = 0; i < particleCount; i++) {
      final x = (random * (i + 1) * 7919) % size.width;
      final y = (random * (i + 3) * 7907 + animationValue * 50) % size.height;
      final opacity = (random * (i + 5) * 7901) % 100 / 100;
      final double radius = (random * (i + 7) * 7883) % 3 + 1;
      
      final paint = Paint()
        ..color = particleColor.withOpacity(opacity * 0.6)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(SmogParticlesPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

// Health Tips Data
class HealthTip {
  final String title;
  final String description;
  final IconData icon;
  
  HealthTip({
    required this.title,
    required this.description,
    required this.icon,
  });
}

// Health Tips for Different AQI Levels
final List<HealthTip> _goodAQITips = [
  HealthTip(
    title: 'Enjoy Outdoor Activities',
    description: 'Air quality is good. It\'s a perfect time for outdoor exercises and activities.',
    icon: Icons.nature_people,
  ),
  HealthTip(
    title: 'Open Windows',
    description: 'Let fresh air circulate in your home by opening windows.',
    icon: Icons.window,
  ),
  HealthTip(
    title: 'Normal Activities',
    description: 'Continue with your normal activities without any restrictions.',
    icon: Icons.check_circle,
  ),
];

final List<HealthTip> _moderateAQITips = [
  HealthTip(
    title: 'Sensitive Groups Caution',
    description: 'If you have respiratory issues, consider reducing prolonged outdoor exertion.',
    icon: Icons.health_and_safety,
  ),
  HealthTip(
    title: 'Monitor Symptoms',
    description: 'Pay attention to any respiratory symptoms that may develop.',
    icon: Icons.visibility,
  ),
  HealthTip(
    title: 'Keep Medications Handy',
    description: 'If you have asthma, keep your medications available.',
    icon: Icons.medical_services,
  ),
];

final List<HealthTip> _unhealthySensitiveTips = [
  HealthTip(
    title: 'Reduce Outdoor Activities',
    description: 'People with heart or lung disease, older adults, and children should reduce prolonged or heavy outdoor exertion.',
    icon: Icons.directions_walk,
  ),
  HealthTip(
    title: 'Keep Windows Closed',
    description: 'Keep windows closed to prevent outdoor air pollution from coming inside.',
    icon: Icons.window,
  ),
  HealthTip(
    title: 'Use Air Purifiers',
    description: 'Consider using air purifiers with HEPA filters indoors.',
    icon: Icons.air,
  ),
];

final List<HealthTip> _unhealthyTips = [
  HealthTip(
    title: 'Limit Outdoor Activities',
    description: 'Everyone should limit prolonged outdoor exertion. Move activities indoors or reschedule.',
    icon: Icons.do_not_touch,
  ),
  HealthTip(
    title: 'Wear Masks Outdoors',
    description: 'Use N95 masks when going outside to reduce exposure to pollutants.',
    icon: Icons.masks,
  ),
  HealthTip(
    title: 'Stay Hydrated',
    description: 'Drink plenty of water to help flush toxins from your body.',
    icon: Icons.water_drop,
  ),
  HealthTip(
    title: 'Monitor Health',
    description: 'Watch for symptoms like coughing, throat irritation, or uncomfortable breathing sensations.',
    icon: Icons.monitor_heart,
  ),
];

final List<HealthTip> _veryUnhealthyTips = [
  HealthTip(
    title: 'Avoid Outdoor Activities',
    description: 'Avoid all outdoor physical activities. Stay indoors as much as possible.',
    icon: Icons.not_interested,
  ),
  HealthTip(
    title: 'Use Air Purifiers',
    description: 'Run air purifiers continuously in your home and workplace.',
    icon: Icons.air,
  ),
  HealthTip(
    title: 'Create Clean Room',
    description: 'Designate one room in your home as a clean room with air purifiers and sealed windows.',
    icon: Icons.meeting_room,
  ),
  HealthTip(
    title: 'Avoid Cooking/Smoking',
    description: 'Avoid activities that further pollute indoor air like smoking or frying foods.',
    icon: Icons.smoke_free,
  ),
  HealthTip(
    title: 'Seek Medical Attention',
    description: 'If experiencing respiratory distress, seek medical attention immediately.',
    icon: Icons.local_hospital,
  ),
];

final List<HealthTip> _hazardousTips = [
  HealthTip(
    title: 'Stay Indoors',
    description: 'Everyone should remain indoors with windows and doors closed.',
    icon: Icons.home,
  ),
  HealthTip(
    title: 'Use N99 Masks',
    description: 'If you must go outside, use N99 masks and limit exposure time.',
    icon: Icons.masks,
  ),
  HealthTip(
    title: 'Avoid Physical Exertion',
    description: 'Avoid all physical exertion, both outdoors and indoors.',
    icon: Icons.fitness_center_outlined,
  ),
  HealthTip(
    title: 'Consider Relocation',
    description: 'If possible, consider temporary relocation to an area with better air quality.',
    icon: Icons.transfer_within_a_station,
  ),
  HealthTip(
    title: 'Emergency Preparedness',
    description: 'Keep emergency contact numbers ready and follow public health advisories.',
    icon: Icons.emergency,
  ),
  HealthTip(
    title: 'Seek Medical Help',
    description: 'If experiencing symptoms like chest pain or difficulty breathing, seek emergency medical help immediately.',
    icon: Icons.emergency_share,
  ),
];