import 'dart:math' as math;
import '../models/car_model.dart';
import '../models/player_profile.dart';

class PlayerCar {
  final CarModel model;
  final PlayerProfile profile;

  double worldX = 0.0; // Centered on road
  double worldY = 0.0;
  double worldZ = 0.0;

  double speed = 0.0; // Current speed in km/h
  double topSpeed = 180.0;
  double acceleration = 65.0; // km/h per second
  double handling = 420.0; // Lateral units per second
  double braking = 120.0; // km/h per second
  double nitroMax = 5.0; // Seconds of boost
  double nitroLevel = 5.0;

  bool isAccelerating = false;
  bool isBraking = false;
  bool isNitroActive = false;
  double steerInput = 0.0; // -1.0 to +1.0

  double bodyTilt = 0.0; // Chassis roll in radians
  double wheelRotation = 0.0; // Angle for animated alloy wheels
  bool isCrashed = false;

  PlayerCar({required this.model, required this.profile}) {
    _applyUpgrades();
  }

  void _applyUpgrades() {
    final engineLvl = profile.getUpgradeLevel(model.id, 'engine');
    final accelLvl = profile.getUpgradeLevel(model.id, 'acceleration');
    final handlLvl = profile.getUpgradeLevel(model.id, 'handling');
    final brakeLvl = profile.getUpgradeLevel(model.id, 'brakes');
    final nitroLvl = profile.getUpgradeLevel(model.id, 'nitro');

    topSpeed = model.baseMaxSpeed + (engineLvl * 10.0);
    acceleration = (model.baseAcceleration * 80.0) + (accelLvl * 6.0);
    handling = (model.baseHandling * 480.0) + (handlLvl * 30.0);
    braking = (model.baseBraking * 140.0) + (brakeLvl * 12.0);
    nitroMax = model.baseNitroCapacity + (nitroLvl * 1.5);
    nitroLevel = nitroMax;
  }

  void update(double dt) {
    if (isCrashed) {
      // Rapid deceleration on impact
      speed = math.max(0.0, speed - (300.0 * dt));
      return;
    }

    // Nitro consumption and speed boost
    final double maxPossibleSpeed = isNitroActive ? (topSpeed + 75.0) : topSpeed;
    final double targetAccel = isNitroActive ? (acceleration * 2.2) : acceleration;

    if (isNitroActive) {
      nitroLevel -= dt;
      if (nitroLevel <= 0.0) {
        nitroLevel = 0.0;
        isNitroActive = false;
      }
    }

    // Throttle / Brake speed physics
    if (isBraking) {
      speed = math.max(0.0, speed - (braking * dt));
    } else if (isAccelerating || isNitroActive) {
      if (speed < maxPossibleSpeed) {
        speed = math.min(maxPossibleSpeed, speed + (targetAccel * dt));
      }
    } else {
      // Natural rolling resistance friction
      speed = math.max(0.0, speed - (25.0 * dt));
    }

    // World depth progression (convert km/h to world distance units per second)
    final double distancePerSec = (speed / 3.6) * 12.0;
    worldZ += distancePerSec * dt;

    // Wheel rotation based on distance travelled
    wheelRotation += (distancePerSec * dt * 0.15) % (2 * math.pi);

    // Lateral Steering
    if (speed > 5.0) {
      final double effectiveHandling = handling * (0.6 + 0.4 * (speed / topSpeed));
      worldX += steerInput * effectiveHandling * dt;

      // Keep within road boundaries (-220 to +220)
      worldX = worldX.clamp(-215.0, 215.0);
    }

    // Chassis dynamic banking tilt
    final double targetTilt = steerInput * 0.14; // Up to ~8 degrees of roll
    bodyTilt += (targetTilt - bodyTilt) * math.min(1.0, 10.0 * dt);
  }

  void addNitro(double seconds) {
    nitroLevel = math.min(nitroMax, nitroLevel + seconds);
  }

  void reset(double newZ) {
    worldX = 0.0;
    worldZ = newZ;
    speed = 0.0;
    nitroLevel = nitroMax;
    isNitroActive = false;
    isCrashed = false;
    bodyTilt = 0.0;
  }
}
