import 'package:flutter/material.dart';
import 'package:weather_app/weather_services.dart';

class WeatherProvider with ChangeNotifier {
  WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? weatherData;
  bool isLoading = false;

  Future<void> fetchWeather(String city) async {
    isLoading = true;
    notifyListeners();
    try {
      weatherData = await _weatherService.fetchWeather(city);
    } catch (e) {
      print('Error fetching weather: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchWeatherByLocation(double lat, double lon) async {
    isLoading = true;
    notifyListeners();
    try {
      weatherData = await _weatherService.fetchWeatherByLocation(lat, lon);
    } catch (e) {
      print('Error fetching weather by location: $e');
    }
    isLoading = false;
    notifyListeners();
  }
}
