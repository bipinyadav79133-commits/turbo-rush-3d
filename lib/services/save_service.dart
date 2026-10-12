import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_profile.dart';

class SaveService {
  static const String _keyProfile = 'turbo_rush_profile_v1';

  static Future<PlayerProfile> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyProfile);
      if (jsonStr == null || jsonStr.isEmpty) {
        return PlayerProfile();
      }

      final Map<String, dynamic> map = jsonDecode(jsonStr);
      return PlayerProfile(
        coins: map['coins'] as int? ?? 200,
        highScore: map['highScore'] as int? ?? 0,
        totalDistance: map['totalDistance'] as int? ?? 0,
        selectedCarId: map['selectedCarId'] as String? ?? 'apex_cruiser',
        unlockedCarIds: (map['unlockedCarIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            ['apex_cruiser'],
        upgrades: (map['upgrades'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {},
        soundEnabled: map['soundEnabled'] as bool? ?? true,
        musicEnabled: map['musicEnabled'] as bool? ?? true,
        useTiltControls: map['useTiltControls'] as bool? ?? false,
        currentTheme: map['currentTheme'] as String? ?? 'cyber_night',
      );
    } catch (e) {
      // Fallback on defaults if data read errors
      return PlayerProfile();
    }
  }

  static Future<void> saveProfile(PlayerProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = {
        'coins': profile.coins,
        'highScore': profile.highScore,
        'totalDistance': profile.totalDistance,
        'selectedCarId': profile.selectedCarId,
        'unlockedCarIds': profile.unlockedCarIds,
        'upgrades': profile.upgrades,
        'soundEnabled': profile.soundEnabled,
        'musicEnabled': profile.musicEnabled,
        'useTiltControls': profile.useTiltControls,
        'currentTheme': profile.currentTheme,
      };
      await prefs.setString(_keyProfile, jsonEncode(map));
    } catch (_) {}
  }
}
