import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_rush_3d/models/car_model.dart';
import 'package:turbo_rush_3d/models/player_profile.dart';
import 'package:turbo_rush_3d/entities/player_car.dart';
import 'package:turbo_rush_3d/entities/traffic_vehicle.dart';
import 'package:turbo_rush_3d/entities/coin_pickup.dart';
import 'package:turbo_rush_3d/systems/collision_system.dart';
import 'package:turbo_rush_3d/systems/scoring_system.dart';

void main() {
  group('Player Profile & Upgrades', () {
    test('Default profile has starter car unlocked and starter coins', () {
      final profile = PlayerProfile();
      expect(profile.coins, 200);
      expect(profile.selectedCarId, 'apex_cruiser');
      expect(profile.isCarUnlocked('apex_cruiser'), true);
      expect(profile.isCarUnlocked('hyperion_evo'), false);
    });

    test('Upgrade levels scale car stats', () {
      final profile = PlayerProfile();
      final carModel = CarModel.allCars.first;
      final car = PlayerCar(model: carModel, profile: profile);

      final initialTopSpeed = car.topSpeed;
      profile.setUpgradeLevel(carModel.id, 'engine', 3);
      final upgradedCar = PlayerCar(model: carModel, profile: profile);

      expect(upgradedCar.topSpeed, initialTopSpeed + 30.0);
    });
  });

  group('Player Car Physics', () {
    test('Nitro accelerates car beyond base top speed and drains fuel', () {
      final profile = PlayerProfile();
      final car = PlayerCar(model: CarModel.allCars.first, profile: profile);
      car.isNitroActive = true;
      car.speed = car.topSpeed;

      // Update 0.1s
      car.update(0.1);
      expect(car.nitroLevel, lessThan(car.nitroMax));
      expect(car.speed, greaterThanOrEqualTo(car.topSpeed));
    });

    test('Braking decelerates speed', () {
      final profile = PlayerProfile();
      final car = PlayerCar(model: CarModel.allCars.first, profile: profile);
      car.speed = 100.0;
      car.isBraking = true;
      car.update(0.1);

      expect(car.speed, lessThan(100.0));
    });

    test('Steering moves worldX within highway limits', () {
      final profile = PlayerProfile();
      final car = PlayerCar(model: CarModel.allCars.first, profile: profile);
      car.speed = 80.0;
      car.steerInput = -1.0; // Left
      car.update(0.2);

      expect(car.worldX, lessThan(0.0));
      expect(car.worldX, greaterThanOrEqualTo(-220.0));
    });
  });

  group('Collision and Near Miss System', () {
    test('Detects direct collision when bounds overlap', () {
      final profile = PlayerProfile();
      final car = PlayerCar(model: CarModel.allCars.first, profile: profile);
      car.worldX = 45.0;
      car.worldZ = 100.0;

      final traffic = [
        TrafficVehicle(
          type: TrafficType.sedan,
          laneIndex: 2,
          worldX: 45.0,
          worldZ: 100.0,
          speed: 60.0,
          bodyColor: Colors.blue,
          width: 46.0,
          length: 92.0,
          height: 32.0,
        ),
      ];

      final res = CollisionSystem.checkCollisions(
        player: car,
        traffic: traffic,
        pickups: [],
      );

      expect(res.hasCrashed, true);
    });

    test('Detects near miss when passing close without collision', () {
      final profile = PlayerProfile();
      final car = PlayerCar(model: CarModel.allCars.first, profile: profile);
      car.worldX = 0.0;
      car.worldZ = 140.0; // Player has passed vehicle
      car.speed = 150.0; // High speed

      final traffic = [
        TrafficVehicle(
          type: TrafficType.sedan,
          laneIndex: 2,
          worldX: 55.0, // Safe lateral clearance (> 46 and < 78.2)
          worldZ: 100.0,
          speed: 60.0,
          bodyColor: Colors.blue,
          width: 46.0,
          length: 92.0,
          height: 32.0,
        ),
      ];

      final res = CollisionSystem.checkCollisions(
        player: car,
        traffic: traffic,
        pickups: [],
      );

      expect(res.hasCrashed, false);
      expect(res.nearMiss, true);
    });

    test('Collects coin pickup', () {
      final profile = PlayerProfile();
      final car = PlayerCar(model: CarModel.allCars.first, profile: profile);
      car.worldX = 0.0;
      car.worldZ = 100.0;

      final pickups = [
        PickupItem(
          type: PickupType.coin,
          worldX: 0.0,
          worldZ: 100.0,
        ),
      ];

      final res = CollisionSystem.checkCollisions(
        player: car,
        traffic: [],
        pickups: pickups,
      );

      expect(res.coinsCollected, 1);
      expect(pickups.first.isCollected, true);
    });
  });

  group('Scoring System', () {
    test('Calculates distance and near miss multiplier', () {
      final scoring = ScoringSystem();
      scoring.updateDistance(200.0);
      expect(scoring.score, 100);

      scoring.onNearMiss();
      expect(scoring.nearMissCount, 1);
      expect(scoring.comboMultiplier, 2);
      expect(scoring.score, greaterThan(100));

      scoring.onCoinCollected();
      expect(scoring.coinsThisRun, 1);
    });
  });
}
