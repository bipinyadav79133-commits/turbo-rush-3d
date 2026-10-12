class ScoringSystem {
  int score = 0;
  int coinsThisRun = 0;
  double distanceTravelled = 0.0;
  int comboMultiplier = 1;
  int nearMissCount = 0;
  int overtakesCount = 0;

  void reset() {
    score = 0;
    coinsThisRun = 0;
    distanceTravelled = 0.0;
    comboMultiplier = 1;
    nearMissCount = 0;
    overtakesCount = 0;
  }

  void updateDistance(double newDistance) {
    distanceTravelled = newDistance;
    // Base distance points: 1 point every 2 meters
    score = (distanceTravelled * 0.5).toInt() +
        (overtakesCount * 30) +
        (nearMissCount * 80) +
        (coinsThisRun * 10);
  }

  void onNearMiss() {
    nearMissCount++;
    comboMultiplier = (comboMultiplier + 1).clamp(1, 5);
    score += (100 * comboMultiplier);
  }

  void onCoinCollected() {
    coinsThisRun++;
    score += 15;
  }
}
