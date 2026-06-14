import 'dart:convert'; // Wajib untuk membaca data JSON
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/weather_screen.dart';
import 'services/notification_service.dart';
import 'models/weather_model.dart';

// --- NOTIFIERS GLOBAL (Pusat Kendali Aplikasi) ---
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
final ValueNotifier<Locale> languageNotifier = ValueNotifier(const Locale('id'));
final ValueNotifier<String> unitNotifier = ValueNotifier("Celsius");
final ValueNotifier<Weather?> currentWeatherNotifier = ValueNotifier(null);
final ValueNotifier<String> userNameNotifier = ValueNotifier("Weather User");
final ValueNotifier<bool> autoLocationNotifier = ValueNotifier(true);
final ValueNotifier<bool> notificationsEnabledNotifier = ValueNotifier(true);

void main() async {
  // Pastikan sistem Flutter siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inisialisasi Layanan Notifikasi HP
  await NotificationService.init();
  
  // 2. Memuat Semua Pengaturan Tersimpan dari Memori HP (SharedPreferences)
  final prefs = await SharedPreferences.getInstance();
  
  userNameNotifier.value = prefs.getString('user_name') ?? "Weather User";
  autoLocationNotifier.value = prefs.getBool('auto_location') ?? true;
  notificationsEnabledNotifier.value = prefs.getBool('notifications_enabled') ?? true;
  unitNotifier.value = prefs.getString('temp_unit') ?? "Celsius";
  
  // Muat Bahasa Terakhir
  String savedLang = prefs.getString('language_code') ?? 'id';
  languageNotifier.value = Locale(savedLang);
  
  // Muat Tema Terakhir
  String savedTheme = prefs.getString('theme_mode') ?? 'dark';
  themeNotifier.value = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

  // 3. FITUR AUTO-SAVE (Simpan otomatis setiap kali ada perubahan di Settings)
  themeNotifier.addListener(() => prefs.setString('theme_mode', themeNotifier.value == ThemeMode.dark ? 'dark' : 'light'));
  languageNotifier.addListener(() => prefs.setString('language_code', languageNotifier.value.languageCode));
  unitNotifier.addListener(() => prefs.setString('temp_unit', unitNotifier.value));
  userNameNotifier.addListener(() => prefs.setString('user_name', userNameNotifier.value));
  autoLocationNotifier.addListener(() => prefs.setBool('auto_location', autoLocationNotifier.value));
  notificationsEnabledNotifier.addListener(() => prefs.setBool('notifications_enabled', notificationsEnabledNotifier.value));

  // 4. LOGIKA UPDATE NOTIFIKASI CONTROL CENTER (ON/OFF OTOMATIS)
  void updateNotification() {
    // Jika toggle dimatikan di Settings, langsung hapus notifikasi dari HP
    if (!notificationsEnabledNotifier.value) {
      NotificationService.cancelNotification();
      return;
    }

    final weather = currentWeatherNotifier.value;
    if (weather != null) {
      double temp = weather.temperature;
      String unitLabel = unitNotifier.value == "Celsius" ? "°C" : "°F";
      
      if (unitNotifier.value == "Fahrenheit") {
        temp = (temp * 9 / 5) + 32;
      }

      NotificationService.showWeatherNotification(
        city: weather.cityName,
        temp: "${temp.round()}$unitLabel",
        condition: weather.mainCondition,
      );
    }
  }

  // Daftarkan listener agar notifikasi HP selalu sinkron
  currentWeatherNotifier.addListener(updateNotification);
  unitNotifier.addListener(updateNotification);
  notificationsEnabledNotifier.addListener(updateNotification);

  // 5. MUAT DATA CUACA TERAKHIR (Fix Error: Gunakan jsonDecode)
  String? lastWeatherJson = prefs.getString('last_weather');
  if (lastWeatherJson != null) {
    try {
      final decodedData = jsonDecode(lastWeatherJson);
      currentWeatherNotifier.value = Weather.fromLocalJson(decodedData);
      // Munculkan notifikasi saat aplikasi dibuka jika toggle aktif
      if (notificationsEnabledNotifier.value) {
        updateNotification();
      }
    } catch (e) {
      debugPrint("Gagal muat cache cuaca: $e");
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: languageNotifier,
          builder: (context, currentLocale, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Weather App Pro',
              themeMode: currentMode,
              locale: currentLocale,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('id'), Locale('en'), Locale('ja'), Locale('ko'),
                Locale('zh'), Locale('es'), Locale('fr'), Locale('de'),
                Locale('ru'), Locale('ar'), Locale('pt'), Locale('it'),
                Locale('nl'), Locale('tr'), Locale('vi'), Locale('th'),
                Locale('hi'), Locale('pl'), Locale('sv'), Locale('da'),
              ],
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B4DB)),
                scaffoldBackgroundColor: Colors.white,
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B4DB), brightness: Brightness.dark),
                scaffoldBackgroundColor: const Color(0xFF1e3c72),
              ),
              home: const WeatherScreen(),
            );
          },
        );
      },
    );
  }
}
