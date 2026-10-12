import 'package:flutter/material.dart';
import '../app/theme.dart';

class GameOverScreen extends StatelessWidget {
  final int finalScore;
  final int coinsEarned;
  final double distance;
  final int nearMisses;
  final bool isNewHighScore;
  final VoidCallback onRetry;
  final VoidCallback onGarage;
  final VoidCallback onMainMenu;

  const GameOverScreen({
    super.key,
    required this.finalScore,
    required this.coinsEarned,
    required this.distance,
    required this.nearMisses,
    required this.isNewHighScore,
    required this.onRetry,
    required this.onGarage,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.82),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: TurboTheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isNewHighScore ? TurboTheme.neonGold : TurboTheme.neonRed.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: isNewHighScore ? TurboTheme.goldGlow(blur: 24) : TurboTheme.pinkGlow(blur: 20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Icon & Title
                Icon(
                  isNewHighScore ? Icons.emoji_events_rounded : Icons.car_crash_rounded,
                  color: isNewHighScore ? TurboTheme.neonGold : TurboTheme.neonRed,
                  size: 52,
                ),
                const SizedBox(height: 8),
                Text(
                  isNewHighScore ? 'NEW RECORD!' : 'WRECKED!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: isNewHighScore ? TurboTheme.neonGold : TurboTheme.neonRed,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 18),

                // Score Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'FINAL SCORE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: TurboTheme.textMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$finalScore',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Match Statistics Grid
                Row(
                  children: [
                    _buildStatCard('DISTANCE', '${distance.toInt()} M', Icons.route_rounded, TurboTheme.neonCyan),
                    const SizedBox(width: 10),
                    _buildStatCard('COINS', '+$coinsEarned', Icons.monetization_on_rounded, TurboTheme.neonGold),
                    const SizedBox(width: 10),
                    _buildStatCard('NEAR MISS', '$nearMisses', Icons.flash_on_rounded, TurboTheme.neonPink),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TurboTheme.neonCyan,
                      foregroundColor: const Color(0xFF090D16),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.replay_rounded, size: 22),
                    label: const Text('RACE AGAIN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onGarage,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.garage_rounded, size: 18),
                        label: const Text('GARAGE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onMainMenu,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TurboTheme.textMuted,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.home_rounded, size: 18),
                        label: const Text('MENU', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: TurboTheme.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
