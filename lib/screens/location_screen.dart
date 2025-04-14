import 'package:flutter/material.dart';

class LocationSelector extends StatefulWidget {
  const LocationSelector({Key? key}) : super(key: key);

  @override
  _LocationSelectorState createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  String _selectedLocation = 'Delhi';
  final List<String> _delhiLocations = [
    'Delhi',
    'North Delhi',
    'South Delhi',
    'East Delhi',
    'West Delhi',
    'Central Delhi',
    'Noida',
    'Gurgaon',
    'Faridabad',
    'Ghaziabad',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, const Color(0xFFF5F5F7)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Box
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search location...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF4A80F0)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onChanged: (value) {
                      // In a real app, this would filter locations
                      // This is a placeholder for now
                    },
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // Current Location Button
                GestureDetector(
                  onTap: () {
                    // In a real app, this would use geolocator to get current location
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Using current location: Delhi')),
                    );
                    setState(() {
                      _selectedLocation = 'Delhi';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.my_location, color: Color(0xFF4A80F0)),
                        SizedBox(width: 15),
                        Text(
                          'Use current location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // Popular Locations Title
                const Text(
                  'Delhi NCR Locations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Locations List
                Expanded(
                  child: ListView.builder(
                    itemCount: _delhiLocations.length,
                    itemBuilder: (context, index) {
                      final location = _delhiLocations[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        leading: Icon(
                          Icons.location_on,
                          color: _selectedLocation == location 
                              ? const Color(0xFF4A80F0) 
                              : Colors.grey,
                        ),
                        title: Text(
                          location,
                          style: TextStyle(
                            fontWeight: _selectedLocation == location 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                          ),
                        ),
                        tileColor: _selectedLocation == location 
                            ? const Color(0xFFEDF1FF) 
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedLocation = location;
                          });
                          // In a real app, you would pass this location back to the main page
                          Future.delayed(const Duration(milliseconds: 300), () {
                            Navigator.pop(context, location);
                          });
                        },
                      );
                    },
                  ),
                ),
                
                // Map Preview (Placeholder)
                Container(
                  height: 150,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: const DecorationImage(
                      image: NetworkImage('https://www.mapsof.net/delhi/delhi-districts-map?image=full'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedLocation);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A80F0),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}