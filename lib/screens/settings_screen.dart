import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/player_profile.dart';
import '../services/save_service.dart';
import '../services/audio_service.dart';

class SettingsScreen extends StatefulWidget {
  final PlayerProfile profile;
  final VoidCallback onBack;

  const SettingsScreen({
    super.key,
    required this.profile,
    required this.onBack,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _sound;
  late bool _music;
  late bool _tilt;
  late String _theme;

  @override
  void initState() {
    super.initState();
    _sound = widget.profile.soundEnabled;
    _music = widget.profile.musicEnabled;
    _tilt = widget.profile.useTiltControls;
    _theme = widget.profile.currentTheme;
  }

  void _saveChanges() {
    widget.profile.soundEnabled = _sound;
    widget.profile.musicEnabled = _music;
    widget.profile.useTiltControls = _tilt;
    widget.profile.currentTheme = _theme;
    AudioService.instance.soundEnabled = _sound;
    AudioService.instance.musicEnabled = _music;
    SaveService.saveProfile(widget.profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TurboTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _saveChanges();
                      widget.onBack();
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SETTINGS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  children: [
                    _buildSectionHeader('AUDIO & HAPTICS'),
                    _buildSwitchTile(
                      title: 'Sound Effects & Haptics',
                      subtitle: 'Engine, nitro, coin chimes and collision feedback',
                      value: _sound,
                      onChanged: (val) {
                        setState(() => _sound = val);
                        _saveChanges();
                      },
                    ),
                    _buildSwitchTile(
                      title: 'Music',
                      subtitle: 'Cyberpunk racing soundtrack in menus and gameplay',
                      value: _music,
                      onChanged: (val) {
                        setState(() => _music = val);
                        _saveChanges();
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader('CONTROLS'),
                    _buildSwitchTile(
                      title: 'Tilt Steering (Gyro / Accelerometer)',
                      subtitle: _tilt ? 'Steer by tilting device left/right' : 'On-screen touch buttons enabled',
                      value: _tilt,
                      onChanged: (val) {
                        setState(() => _tilt = val);
                        _saveChanges();
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader('HIGHWAY ENVIRONMENT THEME'),
                    const SizedBox(height: 8),
                    _buildThemeSelector(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: TurboTheme.neonCyan,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TurboTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: TurboTheme.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: TurboTheme.neonCyan,
            activeTrackColor: TurboTheme.neonCyan.withValues(alpha: 0.4),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    final themes = [
      {'id': 'cyber_night', 'title': 'Cyber Night', 'desc': 'Futuristic neon metropolis with glowing streetlights'},
      {'id': 'sunset_highway', 'title': 'Sunset Horizon', 'desc': 'Vibrant purple and orange highway sunset'},
      {'id': 'desert_canyon', 'title': 'Desert Canyon', 'desc': 'Warm twilight desert highway and canyons'},
    ];

    return Column(
      children: themes.map((t) {
        final isSelected = (_theme == t['id']);
        return GestureDetector(
          onTap: () {
            setState(() => _theme = t['id']!);
            _saveChanges();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: TurboTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? TurboTheme.neonCyan : Colors.white.withValues(alpha: 0.08),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected ? TurboTheme.cyanGlow(blur: 12) : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? TurboTheme.neonCyan : TurboTheme.textDim,
                  size: 20,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t['title']!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? TurboTheme.neonCyan : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t['desc']!,
                        style: const TextStyle(fontSize: 12, color: TurboTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
