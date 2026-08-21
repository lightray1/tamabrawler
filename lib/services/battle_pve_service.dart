import 'dart:math';
import '../models/pet.dart';
import '../models/enemy.dart';

enum Difficulty { easy, medium, hard }

class PvEService {
  final Difficulty difficulty;
  int currentWave = 1;
  late List<Enemy> enemyWaves;

  PvEService({required this.difficulty}) {
    _generateWaves();
  }

  void _generateWaves() {
    enemyWaves = [];
    switch (difficulty) {
      case Difficulty.easy:
        // 3 slimes, 1 bat, 1 boss slime
        enemyWaves.add(Enemy.slime());
        enemyWaves.add(Enemy.slime());
        enemyWaves.add(Enemy.slime());
        enemyWaves.add(Enemy.bat());
        enemyWaves.add(Enemy.slime(isBoss: true));
        break;
      case Difficulty.medium:
        // mixed
        enemyWaves.add(Enemy.slime());
        enemyWaves.add(Enemy.bat());
        enemyWaves.add(Enemy.bat());
        enemyWaves.add(Enemy.goblin());
        enemyWaves.add(Enemy.bat(isBoss: true));
        break;
      case Difficulty.hard:
        // goblins + boss
        enemyWaves.add(Enemy.bat());
        enemyWaves.add(Enemy.goblin());
        enemyWaves.add(Enemy.goblin());
        enemyWaves.add(Enemy.goblin());
        enemyWaves.add(Enemy.goblin(isBoss: true));
        break;
    }
  }

  Enemy getCurrentEnemy() {
    return enemyWaves[currentWave - 1];
  }

  void onWaveComplete(Pet pet) {
    if (currentWave < 5) {
      // Pet recovers 10% HP between waves
      pet.health = min(pet.getMaxStat(), pet.health + 10);
      currentWave++;
    }
  }

  void onBattleVictory(Pet pet, bool isBoss) {
    int gainedXp = isBoss ? 100 : 50;
    pet.levelUp(gainedXp);

    // Random potion simulation (we don't have inventory yet in spec, but spec mentions it)
    // Could just heal health as a "potion"
    if (Random().nextDouble() < 0.3) {
      pet.health = min(pet.getMaxStat(), pet.health + 30); // Use potion immediately as we have no inventory model
    }
  }

  void onBattleDefeat(Pet pet) {
    pet.health = 10;
  }
}
