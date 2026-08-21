import 'dart:math';
import '../models/pet.dart';
import '../models/enemy.dart';

enum BattleAction { attack, defend, special, heal }
enum BattleResult { ongoing, playerWins, enemyWins }

class BattleEngine {
  final Pet playerPet;
  final Enemy enemy;
  int turnCounter = 0;
  List<String> battleLog = [];

  bool playerDefending = false;
  bool enemyDefending = false;

  BattleEngine({required this.playerPet, required this.enemy});

  void log(String message) {
    battleLog.insert(0, message);
    if (battleLog.length > 5) {
      battleLog.removeLast();
    }
  }

  int calculateDamage(int attackPower, int defense) {
    return max(1, attackPower - (defense ~/ 2));
  }

  BattleAction getEnemyAction() {
    final rand = Random().nextDouble(); // 0.0 to 1.0

    // Enemy AI decision logic
    // 50% Attack
    // 25% Defend (if HP<30%)
    // 15% Special (if energy>0) - Wait, enemies don't have energy in the model yet, we'll assume they just have a probability for it or skip energy check
    // 10% Heal (if HP<50%)

    // Normalize probabilities based on conditions
    double attackProb = 0.50;
    double defendProb = (enemy.hp < enemy.maxHp * 0.3) ? 0.25 : 0.0;
    double specialProb = 0.15; // Assuming special can always be used for enemies
    double healProb = (enemy.hp < enemy.maxHp * 0.5) ? 0.10 : 0.0;

    double total = attackProb + defendProb + specialProb + healProb;

    double p = rand * total;

    if (p < attackProb) return BattleAction.attack;
    p -= attackProb;
    if (p < defendProb) return BattleAction.defend;
    p -= defendProb;
    if (p < specialProb) return BattleAction.special;
    return BattleAction.heal;
  }

  String checkVictory() {
    if (playerPet.health <= 0) return 'enemy_wins';
    if (enemy.hp <= 0) return 'player_wins';
    return 'ongoing';
  }

  Map<String, dynamic> executeTurn(BattleAction playerAction, BattleAction enemyAction) {
    turnCounter++;

    int playerDamageTaken = 0;
    int enemyDamageTaken = 0;

    // Reset player defense at start of player turn
    playerDefending = false;

    // Player Turn
    enemyDamageTaken = _executeAction(playerPet.name, playerAction, true);

    String victoryStatus = checkVictory();
    if (victoryStatus == 'player_wins') {
      return {'result': victoryStatus, 'playerDamageTaken': playerDamageTaken, 'enemyDamageTaken': enemyDamageTaken};
    }

    // Reset enemy defense at start of enemy turn
    enemyDefending = false;

    // Enemy Turn
    playerDamageTaken = _executeAction(enemy.name, enemyAction, false);

    victoryStatus = checkVictory();

    return {'result': victoryStatus, 'playerDamageTaken': playerDamageTaken, 'enemyDamageTaken': enemyDamageTaken};
  }

  int _executeAction(String actorName, BattleAction action, bool isPlayer) {
    int damageTaken = 0;
    switch (action) {
      case BattleAction.attack:
        if (isPlayer) {
          int enemyDef = enemyDefending ? (enemy.defense * 1.5).floor() : enemy.defense;
          damageTaken = calculateDamage(playerPet.battleAttack, enemyDef);
          enemy.hp = max(0, enemy.hp - damageTaken);
        } else {
          int playerDef = playerDefending ? (playerPet.battleDefense * 1.5).floor() : playerPet.battleDefense;
          damageTaken = calculateDamage(enemy.attack, playerDef);
          playerPet.health = max(0, playerPet.health - damageTaken);
        }
        log("$actorName used Attack! ($damageTaken DMG)");
        break;
      case BattleAction.defend:
        if (isPlayer) {
          playerDefending = true;
        } else {
          enemyDefending = true;
        }
        log("$actorName used Defend!");
        break;
      case BattleAction.special:
        if (isPlayer) {
          if (playerPet.energy >= 15) {
            playerPet.energy -= 15;
            int enemyDef = enemyDefending ? (enemy.defense * 1.5).floor() : enemy.defense;
            damageTaken = calculateDamage(playerPet.battleAttack * 2, enemyDef);
            enemy.hp = max(0, enemy.hp - damageTaken);
            log("$actorName used Special! ($damageTaken DMG)");
          } else {
            log("$actorName tried to use Special but lacked energy!");
          }
        } else {
          // Enemy special
          int playerDef = playerDefending ? (playerPet.battleDefense * 1.5).floor() : playerPet.battleDefense;
          damageTaken = calculateDamage(enemy.attack * 2, playerDef);
          playerPet.health = max(0, playerPet.health - damageTaken);
          log("$actorName used Special! ($damageTaken DMG)");
        }
        break;
      case BattleAction.heal:
        if (!isPlayer) {
          enemy.hp = min(enemy.maxHp, enemy.hp + 15);
          log("$actorName used Heal! (+15 HP)");
        } else {
          // Player heal not standard action in spec, but just in case
          playerPet.health = min(100, playerPet.health + 15);
          log("$actorName used Heal! (+15 HP)");
        }
        break;
    }
    return damageTaken;
  }
}
