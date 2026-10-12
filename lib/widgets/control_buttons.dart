import 'package:flutter/material.dart';
import '../app/theme.dart';

class MobileControlButtons extends StatelessWidget {
  final ValueChanged<double> onSteer;
  final ValueChanged<bool> onBrake;
  final ValueChanged<bool> onNitro;
  final bool isNitroActive;
  final bool canUseNitro;

  const MobileControlButtons({
    super.key,
    required this.onSteer,
    required this.onBrake,
    required this.onNitro,
    required this.isNitroActive,
    required this.canUseNitro,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left Side: Steering Buttons (Left / Right)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildControlButton(
                icon: Icons.arrow_back_ios_new_rounded,
                label: 'LEFT',
                color: TurboTheme.neonCyan,
                onDown: () => onSteer(-1.0),
                onUp: () => onSteer(0.0),
              ),
              const SizedBox(width: 14),
              _buildControlButton(
                icon: Icons.arrow_forward_ios_rounded,
                label: 'RIGHT',
                color: TurboTheme.neonCyan,
                onDown: () => onSteer(1.0),
                onUp: () => onSteer(0.0),
              ),
            ],
          ),

          // Right Side: Brake and Nitro
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Brake Pedal
              _buildControlButton(
                icon: Icons.pan_tool_rounded,
                label: 'BRAKE',
                color: TurboTheme.neonRed,
                onDown: () => onBrake(true),
                onUp: () => onBrake(false),
              ),
              const SizedBox(width: 14),
              // Nitro Boost
              _buildControlButton(
                icon: Icons.bolt_rounded,
                label: 'NITRO',
                color: isNitroActive ? TurboTheme.neonPink : TurboTheme.neonGold,
                isPulsing: isNitroActive,
                isEnabled: canUseNitro,
                onDown: () {
                  if (canUseNitro) onNitro(true);
                },
                onUp: () => onNitro(false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onDown,
    required VoidCallback onUp,
    bool isPulsing = false,
    bool isEnabled = true,
  }) {
    return Listener(
      onPointerDown: (_) {
        if (isEnabled) onDown();
      },
      onPointerUp: (_) => onUp(),
      onPointerCancel: (_) => onUp(),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.45,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: TurboTheme.surface.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.7),
              width: 2.0,
            ),
            boxShadow: isPulsing
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
