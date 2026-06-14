import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../models/weather_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../main.dart'; // Import Notifiers

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  Weather? _weather;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedWeather();
  }

  _loadSavedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString('last_weather');
    if (jsonStr != null) {
      setState(() {
        _weather = Weather.fromLocalJson(jsonDecode(jsonStr));
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  // Fungsi Konversi Suhu
  String _formatTemp(double tempC, String unit) {
    if (unit == "Fahrenheit") {
      double tempF = (tempC * 9 / 5) + 32;
      return "${tempF.round()}°";
    }
    return "${tempC.round()}°";
  }

  // URL Lottie baru yang lebih stabil (sama dengan home_screen)
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

  Widget _buildWeatherIcon(String condition) {
    IconData iconData;
    switch (condition.toLowerCase()) {
      case 'clouds': iconData = Icons.wb_cloudy_rounded; break;
      case 'rain': iconData = Icons.umbrella_rounded; break;
      case 'thunderstorm': iconData = Icons.flash_on_rounded; break;
      case 'clear': iconData = Icons.wb_sunny_rounded; break;
      default: iconData = Icons.wb_cloudy_rounded;
    }
    return Icon(iconData, color: Colors.white, size: 30);
  }

  @override
  Widget build(BuildContext context) {
    final String locale = languageNotifier.value.languageCode;
    final bool isEn = locale == 'en';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(isEn ? "7-Day Forecast" : "Ramalan 7 Hari", 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: SpinKitWave(color: Colors.white, size: 30))
          : _weather == null
              ? Center(child: Text(isEn ? "Data not available" : "Data tidak tersedia", 
                  style: const TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 100),
                  itemCount: _weather!.dailyForecast.length,
                  itemBuilder: (context, index) {
                    final f = _weather!.dailyForecast[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  index == 0 
                                      ? (isEn ? "Today" : "Hari Ini") 
                                      : DateFormat('EEEE', locale).format(f.date),
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  DateFormat('d MMMM', locale).format(f.date),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 50,
                              child: Lottie.network(
                                _getWeatherAnimation(f.condition),
                                errorBuilder: (context, error, stackTrace) => _buildWeatherIcon(f.condition),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ValueListenableBuilder<String>(
                              valueListenable: unitNotifier,
                              builder: (context, unit, _) {
                                return Text(
                                  _formatTemp(f.temp, unit),
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
