class Weather {
  final String cityName;
  final double temperature;
  final String condition;
  final String icon;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final DateTime lastUpdated;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.lastUpdated,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['cityName'] ?? 'Unknown City',
      temperature: json['temperature'] ?? 0.0,
      condition: json['condition'] ?? 'Unknown',
      icon: json['icon'] ?? '🌈',
      feelsLike: json['feelsLike'] ?? 0.0,
      humidity: json['humidity'] ?? 0,
      windSpeed: json['windSpeed'] ?? 0.0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Weather{cityName: $cityName, temperature: $temperature, condition: $condition}';
  }
}
