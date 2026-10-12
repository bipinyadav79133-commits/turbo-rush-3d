import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/car_model.dart';
import '../models/player_profile.dart';
import '../services/save_service.dart';
import '../services/audio_service.dart';
import 'gameplay_screen.dart';
import 'garage_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final PlayerProfile profile;

  const MainMenuScreen({super.key, required this.profile});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  String _selectedMode = 'endless'; // 'endless', 'time_trial', 'traffic_challenge'

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  CarModel get _selectedCar {
    return CarModel.allCars.firstWhere(
      (c) => c.id == widget.profile.selectedCarId,
      orElse: () => CarModel.allCars.first,
    );
  }

  void _startGame() {
    AudioService.instance.playButtonClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => GameplayScreen(
          profile: widget.profile,
          gameMode: _selectedMode,
          onExitToMenu: () {
            Navigator.of(ctx).pop();
            setState(() {});
          },
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _openGarage() {
    AudioService.instance.playButtonClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => GarageScreen(
          profile: widget.profile,
          onBack: () {
            Navigator.of(ctx).pop();
            setState(() {});
          },
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _openSettings() {
    AudioService.instance.playButtonClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => SettingsScreen(
          profile: widget.profile,
          onBack: () {
            Navigator.of(ctx).pop();
            setState(() {});
          },
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final car = _selectedCar;

    return Scaffold(
      backgroundColor: TurboTheme.background,
      body: Stack(
        children: [
          // Background Cyber Grid / Ambient Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.2),
                  radius: 1.2,
                  colors: [
                    Color(0xFF131D38),
                    Color(0xFF070B14),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Column(
                children: [
                  // 1. Top Bar: Coins, Trophy High Score, Audio Toggles
                  _buildTopBar(),

                  const Spacer(flex: 1),

                  // 2. Main Content Row: (Car Preview on Left) & (Title + Modes + Play on Right)
                  Expanded(
                    flex: 8,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Selected Car Card & 3D Preview
                        Expanded(
                          flex: 5,
                          child: _buildCarShowcaseCard(car),
                        ),

                        const SizedBox(width: 24),

                        // Right: Title, Game Mode Selection, Start Race CTA
                        Expanded(
                          flex: 6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title
                              _buildGameTitle(),

                              const SizedBox(height: 18),

                              // Mode Selector
                              _buildModeSelector(),

                              const SizedBox(height: 20),

                              // Play Race Button
                              _buildPlayButton(),

                              const SizedBox(height: 12),

                              // Garage & Settings Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildNavButton(
                                      icon: Icons.garage_rounded,
                                      label: 'GARAGE & TUNING',
                                      color: TurboTheme.neonCyan,
                                      onTap: _openGarage,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildNavButton(
                                      icon: Icons.settings_rounded,
                                      label: 'SETTINGS',
                                      color: TurboTheme.textSecondary,
                                      onTap: _openSettings,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        // Coins Counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: TurboTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: TurboTheme.neonGold.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on_rounded, color: TurboTheme.neonGold, size: 20),
              const SizedBox(width: 8),
              Text(
                '${widget.profile.coins}',
                style: const TextStyle(
                  color: TurboTheme.neonGold,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // High Score
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: TurboTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: TurboTheme.neonCyan.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, color: TurboTheme.neonCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'BEST: ${widget.profile.highScore}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Audio Toggle Shortcut
        IconButton(
          icon: Icon(
            widget.profile.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            color: widget.profile.soundEnabled ? TurboTheme.neonCyan : TurboTheme.textMuted,
          ),
          tooltip: 'Toggle Sound',
          onPressed: () {
            setState(() {
              widget.profile.soundEnabled = !widget.profile.soundEnabled;
              AudioService.instance.soundEnabled = widget.profile.soundEnabled;
              SaveService.saveProfile(widget.profile);
            });
          },
        ),
      ],
    );
  }

  Widget _buildGameTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: TurboTheme.neonPink.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: TurboTheme.neonPink, width: 1),
              ),
              child: const Text(
                'ENDLESS HIGHWAY ARCADE',
                style: TextStyle(
                  color: TurboTheme.neonPink,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00F2FE), Color(0xFF4FACFE), Color(0xFFFF007F)],
          ).createShader(bounds),
          child: const Text(
            'TURBO RUSH 3D',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarShowcaseCard(CarModel car) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TurboTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: car.primaryColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: car.primaryColor.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Car Name & Subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      car.subtitle,
                      style: TextStyle(
                        color: car.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _openGarage,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  backgroundColor: TurboTheme.background,
                ),
                icon: const Icon(Icons.tune_rounded, size: 16, color: TurboTheme.neonCyan),
                label: const Text(
                  'CHANGE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: TurboTheme.neonCyan),
                ),
              ),
            ],
          ),

          // Visual 3D Car Silhouette
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final wobble = math.sin(_pulseController.value * math.pi * 2) * 4.0;
                  return Transform.translate(
                    offset: Offset(0, wobble),
                    child: Container(
                      width: 220,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            car.primaryColor.withValues(alpha: 0.8),
                            car.accentColor.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(50),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: car.primaryColor.withValues(alpha: 0.4),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Cabin window
                          Positioned(
                            top: 14,
                            left: 55,
                            width: 100,
                            height: 38,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white24, width: 1),
                              ),
                            ),
                          ),
                          // GT Spoiler wing
                          Positioned(
                            left: 10,
                            top: 22,
                            child: Container(
                              width: 28,
                              height: 6,
                              decoration: BoxDecoration(
                                color: car.accentColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          // Neon Headlights
                          Positioned(
                            right: 12,
                            top: 40,
                            child: Container(
                              width: 12,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: TurboTheme.neonCyan,
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Mini Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('TOP SPEED', '${car.baseMaxSpeed.toInt()} km/h'),
              _buildMiniStat('ACCEL', '${(car.baseAcceleration * 100).toInt()}%'),
              _buildMiniStat('NITRO', '${car.baseNitroCapacity.toStringAsFixed(1)}s'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: TurboTheme.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        _buildModeChip('endless', 'ENDLESS', Icons.all_inclusive_rounded),
        const SizedBox(width: 8),
        _buildModeChip('time_trial', 'TIME TRIAL', Icons.timer_rounded),
        const SizedBox(width: 8),
        _buildModeChip('traffic_challenge', 'CHALLENGE', Icons.sports_score_rounded),
      ],
    );
  }

  Widget _buildModeChip(String modeKey, String label, IconData icon) {
    final isSelected = _selectedMode == modeKey;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          AudioService.instance.playButtonClick();
          setState(() {
            _selectedMode = modeKey;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? TurboTheme.neonCyan.withValues(alpha: 0.18) : TurboTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? TurboTheme.neonCyan : Colors.white12,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? TurboTheme.neonCyan : TurboTheme.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : TurboTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.03);
        return Transform.scale(
          scale: scale,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00FF87), Color(0xFF60EFFF)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF87).withValues(alpha: 0.4 + (_pulseController.value * 0.3)),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.play_arrow_rounded, color: Color(0xFF070B14), size: 30),
              label: const Text(
                'START RACE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF070B14),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5), width: 1.2),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: TurboTheme.surface,
      ),
      icon: Icon(icon, size: 20, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
