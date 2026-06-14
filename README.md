# 🌤️ Weather App Pro - Pantau Cuaca dengan Gaya Modern

Aplikasi Cuaca Flutter yang menggabungkan akurasi data dengan desain **Glassmorphism** yang elegan. Aplikasi ini dirancang untuk memberikan informasi cuaca real-time dengan animasi yang halus dan antarmuka pengguna yang sangat nyaman di mata.

🚀 **Versi Terbaru:** v3.1.0
👨‍💻 **Developer:** Rafael Paulus Sitompul
🔗 **Repository:** https://github.com/TEKNIKINFORMATIKA280/weather_app.git

---

## ✨ Fitur Unggulan

Aplikasi ini hadir dengan fitur canggih yang dapat diakses melalui Navbar modern:

1.  🏠 **Beranda (Home)**
    *   **Data Real-Time**: Pantau suhu, kelembapan, dan kecepatan angin secara langsung.
    *   **Halo User**: Sapaan personal berdasarkan nama yang Anda atur di Settings.
    *   **Visual Dinamis**: Latar belakang aplikasi yang berubah warna secara otomatis mengikuti tema.
    *   **Animasi Lottie Host**: Menggunakan server Lottie terbaru untuk stabilitas visual.

2.  📅 **Ramalan (Forecast)**
    *   **Prediksi 7 Hari**: Rencanakan aktivitas mingguan Anda dengan ramalan cuaca detail.
    *   **Konversi Suhu Otomatis**: Mendukung tampilan Celsius dan Fahrenheit secara instan.

3.  🔍 **Pencarian (Search)**
    *   **Global Search**: Cari kondisi cuaca di kota mana pun (Jakarta, Medan, London, dll).
    *   **Manage History**: Fitur hapus riwayat satu per satu (Swipe) atau hapus semua sekaligus.

4.  ⚙️ **Pengaturan (Settings)**
    *   **Multi-Bahasa**: Mendukung 20 bahasa dunia termasuk Indonesia, Inggris, Jepang, Korea, dll.
    *   **Lacak Lokasi Otomatis**: Fitur untuk mendeteksi posisi GPS Anda secara otomatis di mana pun berada.
    *   **Live Notification**: Notifikasi cuaca yang tetap ada di Control Center HP Anda.

---

## 🛠️ Teknologi & Paket (Tech Stack)

Aplikasi ini dibangun menggunakan teknologi mutakhir:

*   **Framework**: [Flutter](https://flutter.dev/) (Material 3)
*   **Layanan API**: [Open-Meteo](https://open-meteo.com/) (Gratis & Akurat)
*   **Reverse Geocoding**: Mendapatkan nama kota otomatis dari koordinat GPS.
*   **Manajemen State**: `ValueNotifier` untuk sinkronisasi data antar layar.
*   **Paket Utama**:
    *   `geolocator` & `geocoding`: Lokasi presisi & Nama kota.
    *   `flutter_local_notifications`: Notifikasi Control Center.
    *   `share_plus`: Fitur undang teman.
    *   `shared_preferences`: Auto-save pengaturan user.

---

## 🚀 Cara Instalasi

1.  **Clone Project:**
    ```bash
    git clone https://github.com/TEKNIKINFORMATIKA280/weather_app.git
    ```
2.  **Install Dependensi:**
    ```bash
    flutter pub get
    ```
3.  **Jalankan:**
    ```bash
    flutter run
    ```

---

Dibuat dengan ❤️ oleh **Rafael Paulus Sitompul**.
© 2026 Proyek Aplikasi Cuaca Modern.
