import 'package:flutter/material.dart';

class AppTheme {
  // App colors
  static const Color primaryColor = Color(0xFF3F51B5);
  static const Color secondaryColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color darkBackgroundColor = Color(0xFF212121);
  
  // AQI Category colors
  static const Color goodAQI = Color(0xFF4CAF50);
  static const Color moderateAQI = Color(0xFFFFC107);
  static const Color unhealthySensitiveAQI = Color(0xFFFF9800);
  static const Color unhealthyAQI = Color(0xFFE53935);
  static const Color veryUnhealthyAQI = Color(0xFF9C27B0);
  static const Color hazardousAQI = Color(0xFF6A1B9A);

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      color: primaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      color: primaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
    ).copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

// utils/aqi_utils.dart
class AQIUtils {
  static String getAQICategory(int aqi) {
    if (aqi <= 50) {
      return 'Good';
    } else if (aqi <= 100) {
      return 'Moderate';
    } else if (aqi <= 150) {
      return 'Unhealthy for Sensitive Groups';
    } else if (aqi <= 200) {
      return 'Unhealthy';
    } else if (aqi <= 300) {
      return 'Very Unhealthy';
    } else {
      return 'Hazardous';
    }
  }

  static Color getAQIColor(int aqi) {
    if (aqi <= 50) {
      return AppTheme.goodAQI;
    } else if (aqi <= 100) {
      return AppTheme.moderateAQI;
    } else if (aqi <= 150) {
      return AppTheme.unhealthySensitiveAQI;
    } else if (aqi <= 200) {
      return AppTheme.unhealthyAQI;
    } else if (aqi <= 300) {
      return AppTheme.veryUnhealthyAQI;
    } else {
      return AppTheme.hazardousAQI;
    }
  }

  static String getHealthTip(int aqi) {
    if (aqi <= 50) {
      return 'Air quality is considered satisfactory, and air pollution poses little or no risk.';
    } else if (aqi <= 100) {
      return 'Air quality is acceptable; however, for some pollutants there may be a moderate health concern for a very small number of people.';
    } else if (aqi <= 150) {
      return 'Members of sensitive groups may experience health effects. The general public is not likely to be affected.';
    } else if (aqi <= 200) {
      return 'Everyone may begin to experience health effects; members of sensitive groups may experience more serious health effects.';
    } else if (aqi <= 300) {
      return 'Health warnings of emergency conditions. The entire population is more likely to be affected.';
    } else {
      return 'Health alert: everyone may experience more serious health effects.';
    }
  }
}

// models/aqi_data.dart
class AQIData {
  final int aqi;
  final String location;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  AQIData({
    required this.aqi,
    required this.location,
    required this.timestamp,
    this.details,
  });

  // Dummy data generator for the app
  static AQIData getCurrentData() {
    return AQIData(
      aqi: 175,
      location: 'Delhi, India',
      timestamp: DateTime.now(),
      details: {
        'pm2_5': 85.3,
        'pm10': 120.5,
        'o3': 60.2,
        'no2': 45.1,
        'so2': 15.3,
        'co': 1.2,
      },
    );
  }

  static List<AQIData> getPastWeekData() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      return AQIData(
        aqi: 130 + (index * 10) + (index % 2 == 0 ? 20 : -20),
        location: 'Delhi, India',
        timestamp: now.subtract(Duration(days: 6 - index)),
        details: null,
      );
    });
  }

  static List<AQIData> getForecastData() {
    final now = DateTime.now();
    return List.generate(3, (index) {
      return AQIData(
        aqi: 175 + (index * 5) + (index % 2 == 0 ? 15 : -10),
        location: 'Delhi, India',
        timestamp: now.add(Duration(days: index + 1)),
        details: null,
      );
    });
  }
}