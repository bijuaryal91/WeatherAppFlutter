import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:animate_do/animate_do.dart';
import 'weather_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWeatherByLocation(); // Fetch weather using current location on startup
  }

  Future<void> _fetchWeatherByLocation() async {
    final weatherProvider =
        Provider.of<WeatherProvider>(context, listen: false);
    try {
      Position position = await _determinePosition();
      weatherProvider.fetchWeatherByLocation(
          position.latitude, position.longitude);
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return Future.error('Location permissions are permanently denied.');
    }

    // When permissions are granted, return the current position
    return await Geolocator.getCurrentPosition();
  }

  void _searchWeather() {
    final city = _cityController.text;
    if (city.isNotEmpty) {
      final weatherProvider =
          Provider.of<WeatherProvider>(context, listen: false);
      weatherProvider.fetchWeather(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.blueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Consumer<WeatherProvider>(
            builder: (context, weatherProvider, child) {
              if (weatherProvider.isLoading) {
                return const Center(
                  child: SpinKitFadingCircle(
                    color: Colors.white,
                    size: 100.0,
                  ),
                );
              }

              if (weatherProvider.weatherData == null) {
                return Center(
                  child: FadeInDown(
                    delay: const Duration(milliseconds: 500),
                    child: Text(
                      'Enter a city or use your location',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final weatherData = weatherProvider.weatherData!;
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FadeInDown(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        '${weatherData['name']}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeInDown(
                      delay: const Duration(milliseconds: 600),
                      child: Text(
                        '${weatherData['main']['temp']}°C',
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 900),
                      child: Text(
                        '${weatherData['weather'][0]['description']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    SlideInLeft(
                      delay: const Duration(milliseconds: 1200),
                      child: TextField(
                        controller: _cityController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter city name',
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: _searchWeather,
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SlideInRight(
                      delay: const Duration(milliseconds: 1400),
                      child: ElevatedButton(
                        onPressed: _fetchWeatherByLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.8),
                          foregroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        child: const Text('Use Current Location'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
