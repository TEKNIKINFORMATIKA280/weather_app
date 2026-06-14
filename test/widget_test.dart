import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/widgets/weather_info_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Mock SharedPreferences agar tidak error saat test
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Weather App - Unit & Widget Tests', () {
    
    testWidgets('Memastikan UI utama WeatherScreen muncul', (WidgetTester tester) async {
      // Jalankan aplikasi
      await tester.pumpWidget(const MyApp());

      // Verifikasi kolom pencarian kota ada
      expect(find.text('Cari Kota...'), findsOneWidget);

      // Verifikasi keberadaan ikon pencarian
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('WeatherInfoTile menampilkan label dan nilai dengan benar', (WidgetTester tester) async {
      // Test widget WeatherInfoTile secara terisolasi
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherInfoTile(
              icon: Icons.water_drop,
              label: 'Humidity',
              value: '85%',
            ),
          ),
        ),
      );

      // Pastikan teks Humidity dan 85% muncul
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.byIcon(Icons.water_drop), findsOneWidget);
    });

    testWidgets('Mengecek kondisi loading saat aplikasi dimulai', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Pada awal startup, CircularProgressIndicator harus muncul
      // Gunakan pump() untuk memicu satu frame
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
