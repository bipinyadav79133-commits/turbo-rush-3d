import 'package:flutter/material.dart';
import '../app/theme.dart';

class PauseScreen extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;

  const PauseScreen({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: TurboTheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: TurboTheme.neonCyan.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: TurboTheme.cyanGlow(blur: 24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_filled_rounded, color: TurboTheme.neonCyan, size: 56),
              const SizedBox(height: 12),
              const Text(
                'GAME PAUSED',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),

              // Resume Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onResume,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TurboTheme.neonCyan,
                    foregroundColor: const Color(0xFF090D16),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 24),
                  label: const Text('RESUME RACE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 12),

              // Restart Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRestart,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text('RESTART', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 12),

              // Main Menu Button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: onMainMenu,
                  style: TextButton.styleFrom(
                    foregroundColor: TurboTheme.textMuted,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.home_rounded, size: 20),
                  label: const Text('MAIN MENU', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
