import 'package:flutter/material.dart';
import '../models/player_profile.dart';
import '../screens/main_menu_screen.dart';
import 'theme.dart';

class TurboRushApp extends StatelessWidget {
  final PlayerProfile profile;

  const TurboRushApp({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turbo Rush 3D',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: TurboTheme.background,
        colorScheme: const ColorScheme.dark(
          primary: TurboTheme.neonCyan,
          secondary: TurboTheme.neonGreen,
          surface: TurboTheme.surface,
        ),
        fontFamily: 'Roboto',
      ),
      home: MainMenuScreen(profile: profile),
    );
  }
}
