import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();

  final Map<String, String> _languageMap = {
    "Bahasa Indonesia": "id",
    "English": "en",
    "日本語 (Japanese)": "ja",
    "한국어 (Korean)": "ko",
    "中文 (Chinese)": "zh",
    "Español (Spanish)": "es",
    "Français (French)": "fr",
    "Deutsch (German)": "de",
    "Русский (Russian)": "ru",
    "العربية (Arabic)": "ar",
    "Português (Portuguese)": "pt",
    "Italiano (Italian)": "it",
    "Nederlands (Dutch)": "nl",
    "Türkçe (Turkish)": "tr",
    "Tiếng Việt (Vietnamese)": "vi",
    "ไทย (Thai)": "th",
    "हिन्दी (Hindi)": "hi",
    "Polski (Polish)": "pl",
    "Svenska (Swedish)": "sv",
    "Dansk (Danish)": "da",
  };

  String _t(String key) {
    final code = languageNotifier.value.languageCode;
    final Map<String, Map<String, String>> translations = {
      'en': {
        'settings': 'Settings', 'appearance': 'Appearance', 'dark_mode': 'Dark Mode',
        'pref': 'Preferences', 'lang': 'App Language', 'unit': 'Temperature Unit',
        'location': 'Location', 'auto_loc': 'Auto Track Location',
        'notif': 'Notifications', 'live_notif': 'Live Weather Notif',
        'social': 'Community & Social', 'invite': 'Invite Friends', 'rate': 'Rate App',
        'support': 'Support & Legal', 'clear': 'Clear App Data', 'privacy': 'Privacy Policy',
        'edit': 'Edit Name', 'save': 'Save', 'cancel': 'Cancel', 'ver': 'Version'
      },
      'id': {
        'settings': 'Pengaturan', 'appearance': 'Tampilan', 'dark_mode': 'Mode Gelap',
        'pref': 'Preferensi', 'lang': 'Bahasa Aplikasi', 'unit': 'Satuan Suhu',
        'location': 'Lokasi', 'auto_loc': 'Lacak Lokasi Otomatis',
        'notif': 'Notifikasi', 'live_notif': 'Notifikasi Cuaca Live',
        'social': 'Komunitas & Sosial', 'invite': 'Ajak Teman', 'rate': 'Beri Nilai',
        'support': 'Dukungan & Legal', 'clear': 'Hapus Data Aplikasi', 'privacy': 'Kebijakan Privasi',
        'edit': 'Ubah Nama', 'save': 'Simpan', 'cancel': 'Batal', 'ver': 'Versi'
      }
    };
    return (translations[code]?[key]) ?? (translations['en']?[key]) ?? key;
  }

  void _showLegalDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e3c72),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Text(content, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  void _showEditNameDialog() {
    _nameController.text = userNameNotifier.value;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e3c72),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(_t('edit'), style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_t('cancel'))),
          TextButton(
            onPressed: () {
              userNameNotifier.value = _nameController.text;
              Navigator.pop(context);
            }, 
            child: Text(_t('save'), style: const TextStyle(color: Colors.blueAccent))
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1e3c72),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(_t('lang'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _languageMap.length,
                    itemBuilder: (context, index) {
                      final langName = _languageMap.keys.elementAt(index);
                      final langCode = _languageMap[langName]!;
                      final isSelected = languageNotifier.value.languageCode == langCode;
                      return ListTile(
                        title: Text(langName, style: TextStyle(color: isSelected ? Colors.blueAccent : Colors.white)),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blueAccent) : null,
                        onTap: () {
                          languageNotifier.value = Locale(langCode);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = languageNotifier.value.languageCode == 'en';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(_t('settings'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        children: [
          ValueListenableBuilder<String>(
            valueListenable: userNameNotifier,
            builder: (context, name, _) {
              return Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.blue]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 30, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 30)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(isEn ? "Premium Member" : "Member Premium", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: _showEditNameDialog, icon: const Icon(Icons.edit_note, color: Colors.white70)),
                  ],
                ),
              );
            },
          ),

          _buildSectionHeader(_t('appearance')),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              return _buildSettingTile(
                icon: mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                title: _t('dark_mode'),
                trailing: Switch(
                  value: mode == ThemeMode.dark, 
                  onChanged: (v) => themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light,
                  activeThumbColor: Colors.blueAccent,
                ),
              );
            },
          ),

          _buildSectionHeader(_t('pref')),
          _buildSettingTile(
            icon: Icons.language,
            title: _t('lang'),
            subtitle: _languageMap.keys.firstWhere((k) => _languageMap[k] == languageNotifier.value.languageCode, orElse: () => "English"),
            onTap: _showLanguagePicker,
          ),
          ValueListenableBuilder<String>(
            valueListenable: unitNotifier,
            builder: (context, unit, _) {
              return _buildSettingTile(
                icon: Icons.thermostat,
                title: _t('unit'),
                subtitle: unit,
                onTap: () => unitNotifier.value = (unit == "Celsius") ? "Fahrenheit" : "Celsius",
              );
            },
          ),

          _buildSectionHeader(_t('location')),
          ValueListenableBuilder<bool>(
            valueListenable: autoLocationNotifier,
            builder: (context, autoLoc, _) {
              return _buildSettingTile(
                icon: Icons.my_location,
                title: _t('auto_loc'),
                trailing: Switch(
                  value: autoLoc, 
                  onChanged: (v) => autoLocationNotifier.value = v,
                  activeThumbColor: Colors.blueAccent,
                ),
              );
            },
          ),

          _buildSectionHeader(_t('notif')),
          ValueListenableBuilder<bool>(
            valueListenable: notificationsEnabledNotifier,
            builder: (context, enabled, _) {
              return _buildSettingTile(
                icon: Icons.notifications_active_outlined,
                title: _t('live_notif'),
                trailing: Switch(
                  value: enabled, 
                  onChanged: (v) => notificationsEnabledNotifier.value = v,
                  activeThumbColor: Colors.blueAccent,
                ),
              );
            },
          ),

          _buildSectionHeader(_t('social')),
          _buildSettingTile(
            icon: Icons.share,
            title: _t('invite'),
            onTap: () => Share.share(isEn ? "Check out this amazing Weather App! \ud83c\udf26\ufe0f" : "Coba aplikasi cuaca keren ini! \ud83c\udf26\ufe0f"),
          ),
          _buildSettingTile(
            icon: Icons.star_border,
            title: _t('rate'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEn ? "Thank you!" : "Terima kasih!"))),
          ),

          _buildSectionHeader(_t('support')),
          _buildSettingTile(
            icon: Icons.security,
            title: _t('privacy'),
            onTap: () => _showLegalDialog(_t('privacy'), isEn ? "We do not store your personal location data. All data is processed locally." : "Kami tidak menyimpan data lokasi pribadi Anda. Semua data diproses secara lokal."),
          ),
          _buildSettingTile(
            icon: Icons.delete_outline,
            title: _t('clear'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              currentWeatherNotifier.value = null;
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEn ? "App reset successfully" : "Aplikasi berhasil direset")));
            },
          ),

          const SizedBox(height: 30),
          Center(
            child: Column(
              children: [
                Text(_t('ver'), style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14)),
                const Text("v2.1.0", style: TextStyle(color: Colors.white24, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10, top: 15),
      child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)) : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white24),
      ),
    );
  }
}
