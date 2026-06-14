import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import '../main.dart'; 

class SearchScreen extends StatefulWidget {
  final Function(int)? onCityFound; 
  const SearchScreen({super.key, this.onCityFound});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = false;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('search_history') ?? ["Jakarta", "London", "Tokyo"];
    });
  }

  _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', _history);
  }

  void _deleteHistoryItem(int index) {
    setState(() {
      _history.removeAt(index);
    });
    _saveHistory();
  }

  void _clearAllHistory() {
    setState(() {
      _history.clear();
    });
    _saveHistory();
  }

  _searchCity(String city) async {
    if (city.isEmpty) return;
    setState(() => _isLoading = true);
    bool isEn = languageNotifier.value.languageCode == 'en';
    
    try {
      FocusScope.of(context).unfocus();
      final weather = await _weatherService.getWeatherByCity(city);
      
      currentWeatherNotifier.value = weather;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_weather', jsonEncode(weather.toJson()));
      
      if (!_history.contains(weather.cityName)) {
        setState(() {
          _history.insert(0, weather.cityName);
          if (_history.length > 5) _history.removeLast();
        });
        _saveHistory();
      }

      if (widget.onCityFound != null) {
        widget.onCityFound!(0);
      }
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEn ? "City not found: $city" : "Kota tidak ditemukan: $city"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = languageNotifier.value.languageCode == 'en';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(isEn ? "Search City" : "Cari Kota", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: isEn ? "Enter city name..." : "Masukkan nama kota...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  border: InputBorder.none,
                  suffixIcon: _isLoading 
                    ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : IconButton(icon: const Icon(Icons.clear, color: Colors.white), onPressed: () => _searchController.clear()),
                ),
                onSubmitted: _searchCity,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isEn ? "Recent Searches" : "Pencarian Terakhir", 
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                if (_history.isNotEmpty)
                  TextButton(
                    onPressed: _clearAllHistory,
                    child: Text(isEn ? "Clear All" : "Hapus Semua", style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final city = _history[index];
                  // FITUR SWIPE TO DISMISS
                  return Dismissible(
                    key: Key(city),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    onDismissed: (direction) => _deleteHistoryItem(index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.history, color: Colors.white70),
                        title: Text(city, style: const TextStyle(color: Colors.white)),
                        onTap: () => _searchCity(city),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.white38),
                          onPressed: () => _deleteHistoryItem(index),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
