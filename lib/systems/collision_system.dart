import '../entities/player_car.dart';
import '../entities/traffic_vehicle.dart';
import '../entities/coin_pickup.dart';

class CollisionResult {
  final bool hasCrashed;
  final TrafficVehicle? crashedVehicle;
  final int coinsCollected;
  final bool collectedNitro;
  final bool nearMiss;

  const CollisionResult({
    this.hasCrashed = false,
    this.crashedVehicle,
    this.coinsCollected = 0,
    this.collectedNitro = false,
    this.nearMiss = false,
  });
}

class CollisionSystem {
  static const double playerWidth = 46.0;
  static const double playerLength = 94.0;

  static CollisionResult checkCollisions({
    required PlayerCar player,
    required List<TrafficVehicle> traffic,
    required List<PickupItem> pickups,
  }) {
    if (player.isCrashed) {
      return const CollisionResult(hasCrashed: true);
    }

    bool crashed = false;
    TrafficVehicle? hitCar;
    bool nearMissDetected = false;
    int coinsCount = 0;
    bool gotNitro = false;

    final pMinX = player.worldX - (playerWidth / 2);
    final pMaxX = player.worldX + (playerWidth / 2);
    final pMinZ = player.worldZ - (playerLength / 2);
    final pMaxZ = player.worldZ + (playerLength / 2);

    // 1. Check Traffic Collisions and Near Misses
    for (final v in traffic) {
      final vMinX = v.worldX - (v.width / 2);
      final vMaxX = v.worldX + (v.width / 2);
      final vMinZ = v.worldZ - (v.length / 2);
      final vMaxZ = v.worldZ + (v.length / 2);

      // Direct AABB overlap check
      final bool overlapX = (pMinX < vMaxX) && (pMaxX > vMinX);
      final bool overlapZ = (pMinZ < vMaxZ) && (pMaxZ > vMinZ);

      if (overlapX && overlapZ) {
        crashed = true;
        hitCar = v;
        break;
      }

      // Near-miss check: player passes within tight lateral clearance (< 24 units) at high speed
      if (!v.isOvertaken && player.worldZ > v.worldZ + 30.0) {
        final double lateralGap = (player.worldX - v.worldX).abs();
        if (lateralGap < (playerWidth + v.width) * 0.85 && player.speed > 130.0) {
          nearMissDetected = true;
        }
        v.isOvertaken = true;
      }
    }

    // 2. Check Pickups Collection
    for (final p in pickups) {
      if (p.isCollected) continue;

      final double dx = (player.worldX - p.worldX).abs();
      final double dz = (player.worldZ - p.worldZ).abs();

      if (dx < 38.0 && dz < 48.0) {
        p.isCollected = true;
        if (p.type == PickupType.coin) {
          coinsCount++;
        } else if (p.type == PickupType.nitro) {
          gotNitro = true;
        }
      }
    }

    return CollisionResult(
      hasCrashed: crashed,
      crashedVehicle: hitCar,
      coinsCollected: coinsCount,
      collectedNitro: gotNitro,
      nearMiss: nearMissDetected,
    );
  }
}
