import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'services/save_service.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to Landscape for maximum widescreen driving visibility
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Immersive full-screen gaming mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Load persistent player progress (coins, high scores, upgrades)
  final profile = await SaveService.loadProfile();

  // Initialize audio and haptics
  AudioService.instance.init(
    sound: profile.soundEnabled,
    music: profile.musicEnabled,
  );

  runApp(TurboRushApp(profile: profile));
}
