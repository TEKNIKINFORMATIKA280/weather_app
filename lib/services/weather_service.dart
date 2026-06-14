import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart'; // Import untuk melacak nama kota
import '../models/weather_model.dart';
import '../utils/constants.dart';

class WeatherService {
  Future<Weather> getWeatherByCity(String cityName) async {
    // 1. Dapatkan koordinat dari nama kota menggunakan Open-Meteo Geocoding API
    final geoResponse = await http.get(
      Uri.parse('${AppConstants.geoUrl}?name=$cityName&count=1&language=en&format=json'),
    );

    if (geoResponse.statusCode == 200) {
      final data = jsonDecode(geoResponse.body);
      if (data['results'] != null && (data['results'] as List).isNotEmpty) {
        final result = data['results'][0];
        final lat = result['latitude'];
        final lon = result['longitude'];
        final name = result['name'];
        
        return getWeatherByLocation(lat, lon, name);
      } else {
        throw Exception('Kota tidak ditemukan');
      }
    } else {
      throw Exception('Gagal mengambil koordinat');
    }
  }

  Future<Weather> getWeatherByLocation(double lat, double lon, [String? cityName]) async {
    String finalCityName = cityName ?? "Mencari Lokasi...";

    // FITUR OTOMATIS: Jika tidak ada nama kota, lacak nama daerah asli dari koordinat
    if (cityName == null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          // Mengambil nama kota (locality) atau daerah (subAdministrativeArea)
          finalCityName = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? "Lokasi Diketahui";
        }
      } catch (e) {
        finalCityName = "Lokasi Saat Ini";
      }
    }

    final url = '${AppConstants.baseUrl}?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max&timezone=auto';
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Weather.fromOpenMeteo(jsonDecode(response.body), finalCityName);
    } else {
      throw Exception('Gagal memuat data cuaca');
    }
  }
}
