class PlayerProfile {
  int coins;
  int highScore;
  int totalDistance;
  String selectedCarId;
  List<String> unlockedCarIds;
  Map<String, int> upgrades; // key: 'carId_upgradeType', value: level (0..5)

  // Settings
  bool soundEnabled;
  bool musicEnabled;
  bool useTiltControls;
  String currentTheme; // 'cyber_night', 'sunset_highway', 'desert_canyon'

  PlayerProfile({
    this.coins = 200, // Starter bonus
    this.highScore = 0,
    this.totalDistance = 0,
    this.selectedCarId = 'apex_cruiser',
    List<String>? unlockedCarIds,
    Map<String, int>? upgrades,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.useTiltControls = false,
    this.currentTheme = 'cyber_night',
  })  : unlockedCarIds = unlockedCarIds ?? ['apex_cruiser'],
        upgrades = upgrades ?? {};

  int getUpgradeLevel(String carId, String upgradeType) {
    return upgrades['${carId}_$upgradeType'] ?? 0;
  }

  void setUpgradeLevel(String carId, String upgradeType, int level) {
    upgrades['${carId}_$upgradeType'] = level;
  }

  bool isCarUnlocked(String carId) {
    return unlockedCarIds.contains(carId);
  }

  void unlockCar(String carId) {
    if (!unlockedCarIds.contains(carId)) {
      unlockedCarIds.add(carId);
    }
  }
}
