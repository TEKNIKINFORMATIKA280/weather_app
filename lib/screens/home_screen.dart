import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/weather_info_tile.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final _weatherService = WeatherService();
  bool _isLoading = false;
  bool _isOffline = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initAppLogic();
  }

  // Logika Inisialisasi: Cek apakah harus lacak otomatis atau muat data lama
  Future<void> _initAppLogic() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Jika Lacak Otomatis AKTIF, langsung ambil GPS
    if (autoLocationNotifier.value) {
      _fetchWeatherByLocation();
    } else {
      // Jika MATI, muat data terakhir yang disimpan (misal: Medan)
      String? jsonStr = prefs.getString('last_weather');
      if (jsonStr != null) {
        setState(() {
          currentWeatherNotifier.value = Weather.fromLocalJson(jsonDecode(jsonStr));
        });
      } else {
        _fetchWeatherByLocation();
      }
    }
  }

  Future<void> _fetchWeatherByLocation() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _isOffline = false;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Ambil Koordinat GPS Akurat
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      );
      
      // Ambil cuaca + Reverse Geocoding (Cari nama kota otomatis)
      final weather = await _weatherService.getWeatherByLocation(
          position.latitude, position.longitude);
      
      currentWeatherNotifier.value = weather;
      setState(() => _isLoading = false);

      // Simpan sebagai data terakhir
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_weather', jsonEncode(weather.toJson()));

    } catch (e) {
      setState(() {
        _isLoading = false;
        _isOffline = true;
      });
    }
  }

  String _formatTemp(double tempC, String unit) {
    if (unit == "Fahrenheit") {
      double tempF = (tempC * 9 / 5) + 32;
      return "${tempF.round()}°F";
    }
    return "${tempC.round()}°C";
  }

  String _getWeatherAnimation(String? condition) {
    if (condition == null) return 'https://lottie.host/681765c9-9402-409b-980b-99d63c5a6109/H0iE0W5T16.json'; 
    switch (condition.toLowerCase()) {
      case 'clouds': return 'https://lottie.host/96515867-f232-475a-939e-d30c50d4023c/467EwR7i3r.json';
      case 'rain': return 'https://lottie.host/f8148e65-274e-4629-9e32-09418a0028a3/X4J6yC8p9I.json';
      case 'thunderstorm': return 'https://lottie.host/362c1d32-d17b-4029-8736-2f074d081b83/Y6S7yC8p9I.json';
      case 'clear': return 'https://lottie.host/681765c9-9402-409b-980b-99d63c5a6109/H0iE0W5T16.json';
      default: return 'https://lottie.host/96515867-f232-475a-939e-d30c50d4023c/467EwR7i3r.json';
    }
  }

  Widget _buildWeatherIcon(String condition, {double size = 120, required Color color}) {
    IconData iconData;
    switch (condition.toLowerCase()) {
      case 'clouds': iconData = Icons.wb_cloudy_rounded; break;
      case 'rain': iconData = Icons.umbrella_rounded; break;
      case 'thunderstorm': iconData = Icons.flash_on_rounded; break;
      case 'clear': iconData = Icons.wb_sunny_rounded; break;
      default: iconData = Icons.wb_cloudy_rounded;
    }
    return Icon(iconData, color: color, size: size);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black87;
    String locale = languageNotifier.value.languageCode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0), 
        child: FloatingActionButton.small(
          onPressed: _fetchWeatherByLocation,
          backgroundColor: Colors.blueAccent.withOpacity(0.5),
          child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.my_location, color: Colors.white),
        ),
      ),
      body: ValueListenableBuilder<Weather?>(
        valueListenable: currentWeatherNotifier,
        builder: (context, weather, _) {
          if (_isLoading && weather == null) return Center(child: SpinKitPulse(color: textColor, size: 50));
          if (weather == null) return Center(child: Text("No Data", style: TextStyle(color: textColor)));

          return RefreshIndicator(
            onRefresh: _fetchWeatherByLocation,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 120),
              child: Column(
                children: [
                  // Sapaan Nama Pengguna
                  ValueListenableBuilder<String>(
                    valueListenable: userNameNotifier,
                    builder: (context, name, _) {
                      return Text(
                        locale == 'en' ? "Hello, $name!" : "Halo, $name!",
                        style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w500),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  
                  // ICON LOKASI + NAMA KOTA OTOMATIS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: textColor, size: 28),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          weather.cityName.toUpperCase(),
                          style: TextStyle(color: textColor, fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 2),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  Text(DateFormat('EEEE, d MMMM', locale).format(DateTime.now()), style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 16)),
                  
                  SizedBox(
                    height: 200, 
                    child: Lottie.network(
                      _getWeatherAnimation(weather.mainCondition),
                      errorBuilder: (context, error, stackTrace) => _buildWeatherIcon(weather.mainCondition, color: textColor),
                    )
                  ),

                  ValueListenableBuilder<String>(
                    valueListenable: unitNotifier,
                    builder: (context, unit, _) {
                      return Column(
                        children: [
                          Text(_formatTemp(weather.temperature, unit), style: TextStyle(color: textColor, fontSize: 80, fontWeight: FontWeight.w200)),
                          Text(weather.mainCondition.toUpperCase(), style: TextStyle(color: textColor, fontSize: 18, letterSpacing: 5)),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(30)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(child: WeatherInfoTile(icon: Icons.water_drop, label: locale == 'en' ? "Humidity" : "Lembap", value: "${weather.humidity.round()}%")),
                                Expanded(child: WeatherInfoTile(icon: Icons.air, label: locale == 'en' ? "Wind" : "Angin", value: "${weather.windSpeed} m/s")),
                                Expanded(child: WeatherInfoTile(icon: Icons.thermostat, label: locale == 'en' ? "Feels Like" : "Terasa", value: _formatTemp(weather.temperature, unit))),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
