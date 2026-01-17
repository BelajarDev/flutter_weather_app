import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  Future<Map<String, dynamic>> _getCityCoordinates(String cityName) async {
    final response = await http.get(
      Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=$cityName&count=1&language=id&format=json',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return {
          'lat': data['results'][0]['latitude'],
          'lon': data['results'][0]['longitude'],
          'name': data['results'][0]['name'],
        };
      }
    }
    throw Exception('Kota "$cityName" tidak ditemukan');
  }

  Future<Weather> getWeather(String cityName) async {
    try {
      final coords = await _getCityCoordinates(cityName);
      final lat = coords['lat']!;
      final lon = coords['lon']!;
      final actualCityName = coords['name'] ?? cityName;

      final response = await http.get(
        Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&timezone=auto',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return _mapToWeather(data, actualCityName);
      } else {
        throw Exception('Gagal mengambil data cuaca: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Weather _mapToWeather(Map<String, dynamic> data, String cityName) {
    final current = data['current_weather'];

    String getCondition(int code) {
      if (code == 0) return 'Cerah';
      if (code == 1) return 'Cerah Berawan';
      if (code == 2) return 'Berawan';
      if (code == 3) return 'Mendung';
      if (code >= 45 && code <= 48) return 'Berkabut';
      if (code >= 51 && code <= 67) return 'Hujan';
      if (code >= 71 && code <= 77) return 'Salju';
      if (code >= 80 && code <= 82) return 'Hujan Lebat';
      if (code >= 95 && code <= 99) return 'Badai Petir';
      return 'Tidak Diketahui';
    }

    String getIcon(int code) {
      if (code == 0) return '☀️';
      if (code == 1 || code == 2) return '⛅';
      if (code == 3) return '☁️';
      if (code >= 45 && code <= 48) return '🌫️';
      if (code >= 51 && code <= 67) return '🌧️';
      if (code >= 71 && code <= 77) return '❄️';
      if (code >= 80 && code <= 82) return '⛈️';
      if (code >= 95 && code <= 99) return '⛈️';
      return '🌈';
    }

    return Weather(
      cityName: cityName,
      temperature: current['temperature'].toDouble(),
      condition: getCondition(current['weathercode']),
      icon: getIcon(current['weathercode']),
      feelsLike: current['temperature'].toDouble(),
      humidity: 65,
      windSpeed: current['windspeed'].toDouble(),
      lastUpdated: DateTime.parse(current['time']),
    );
  }
}
