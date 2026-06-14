class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final double humidity;
  final double windSpeed;
  final List<DailyForecast> dailyForecast;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.humidity,
    required this.windSpeed,
    required this.dailyForecast,
  });

  // Mapper untuk mengubah Weather Code Open-Meteo ke String Kondisi
  static String mapCodeToCondition(int code) {
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Clouds';
    if (code <= 48) return 'Fog';
    if (code <= 67) return 'Rain';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Rain';
    if (code <= 99) return 'Thunderstorm';
    return 'Clear';
  }

  factory Weather.fromOpenMeteo(Map<String, dynamic> json, String cityName) {
    final current = json['current'];
    final daily = json['daily'];
    
    List<DailyForecast> dailyList = [];
    for (int i = 0; i < (daily['time'] as List).length; i++) {
      dailyList.add(DailyForecast(
        date: DateTime.parse(daily['time'][i]),
        temp: daily['temperature_2m_max'][i].toDouble(),
        condition: mapCodeToCondition(daily['weather_code'][i]),
      ));
    }

    return Weather(
      cityName: cityName,
      temperature: current['temperature_2m'].toDouble(),
      mainCondition: mapCodeToCondition(current['weather_code']),
      humidity: current['relative_humidity_2m'].toDouble(),
      windSpeed: current['wind_speed_10m'].toDouble(),
      dailyForecast: dailyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'mainCondition': mainCondition,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'dailyForecast': dailyForecast.map((x) => x.toJson()).toList(),
    };
  }

  factory Weather.fromLocalJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['cityName'],
      temperature: json['temperature'],
      mainCondition: json['mainCondition'],
      humidity: json['humidity'],
      windSpeed: json['windSpeed'],
      dailyForecast: (json['dailyForecast'] as List)
          .map((i) => DailyForecast.fromLocalJson(i))
          .toList(),
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double temp;
  final String condition;

  DailyForecast({
    required this.date,
    required this.temp,
    required this.condition,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.millisecondsSinceEpoch,
      'temp': temp,
      'condition': condition,
    };
  }

  factory DailyForecast.fromLocalJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      temp: json['temp'],
      condition: json['condition'],
    );
  }
}
