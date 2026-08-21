import 'dart:math';
import '../models/pet.dart';
import 'battle_engine.dart'; // To reuse BattleAction enum

class PvPBattleEngine {
  final Pet player1;
  final Pet player2;
  int turnCounter = 0;
  List<String> battleLog = [];

  bool p1Defending = false;
  bool p2Defending = false;

  PvPBattleEngine({required this.player1, required this.player2});

  void log(String message) {
    battleLog.insert(0, message);
    if (battleLog.length > 5) {
      battleLog.removeLast();
    }
  }

  int calculateDamage(int attackPower, int defense) {
    return max(1, attackPower - (defense ~/ 2));
  }

  String checkVictory() {
    if (player1.health <= 0 && player2.health <= 0) {
      // Very rare double KO case, defaulting to player1_wins or handle as draw
      // For simplicity, let's say higher speed wins ties, else p1.
      if (player1.battleSpeed < player2.battleSpeed) {
        return 'player2_wins';
      }
      return 'player1_wins';
    }
    if (player1.health <= 0) return 'player2_wins';
    if (player2.health <= 0) return 'player1_wins';
    return 'ongoing';
  }

  Map<String, dynamic> executeTurn(BattleAction p1Action, BattleAction p2Action) {
    turnCounter++;

    int p1DamageTaken = 0;
    int p2DamageTaken = 0;

    // Reset defense at start of turn
    p1Defending = false;
    p2Defending = false;

    // First handle defense logic so speed doesn't matter for defending
    if (p1Action == BattleAction.defend) {
      p1Defending = true;
      log("${player1.name} used Defend!");
    }
    if (p2Action == BattleAction.defend) {
      p2Defending = true;
      log("${player2.name} used Defend!");
    }

    // Determine order
    bool p1GoesFirst = player1.battleSpeed >= player2.battleSpeed;

    int dmg = 0;
    if (p1GoesFirst) {
      if (p1Action != BattleAction.defend) {
        dmg = _executeAction(player1, player2, p1Action, p1Defending, p2Defending);
        if (dmg > 0) p2DamageTaken += dmg;
      }
      if (checkVictory() == 'ongoing' && p2Action != BattleAction.defend) {
        dmg = _executeAction(player2, player1, p2Action, p2Defending, p1Defending);
        if (dmg > 0) p1DamageTaken += dmg;
      }
    } else {
      if (p2Action != BattleAction.defend) {
        dmg = _executeAction(player2, player1, p2Action, p2Defending, p1Defending);
        if (dmg > 0) p1DamageTaken += dmg;
      }
      if (checkVictory() == 'ongoing' && p1Action != BattleAction.defend) {
        dmg = _executeAction(player1, player2, p1Action, p1Defending, p2Defending);
        if (dmg > 0) p2DamageTaken += dmg;
      }
    }

    String victoryStatus = checkVictory();
    return {
      'result': victoryStatus,
      'p1DamageTaken': p1DamageTaken,
      'p2DamageTaken': p2DamageTaken,
    };
  }

  int _executeAction(Pet actor, Pet target, BattleAction action, bool actorDefending, bool targetDefending) {
    int damageTaken = 0;
    switch (action) {
      case BattleAction.attack:
        int targetDef = targetDefending ? (target.battleDefense * 1.5).floor() : target.battleDefense;
        damageTaken = calculateDamage(actor.battleAttack, targetDef);
        target.health = max(0, target.health - damageTaken);
        log("${actor.name} used Attack! ($damageTaken DMG)");
        break;
      case BattleAction.special:
        if (actor.energy >= 15) {
          actor.energy -= 15;
          int targetDef = targetDefending ? (target.battleDefense * 1.5).floor() : target.battleDefense;
          damageTaken = calculateDamage(actor.battleAttack * 2, targetDef);
          target.health = max(0, target.health - damageTaken);
          log("${actor.name} used Special! ($damageTaken DMG)");
        } else {
          log("${actor.name} tried to use Special but lacked energy!");
        }
        break;
      case BattleAction.defend:
        // Handled earlier
        break;
      case BattleAction.heal:
        actor.health = min(actor.getMaxStat(), actor.health + 15);
        log("${actor.name} used Heal! (+15 HP)");
        break;
    }
    return damageTaken;
  }
}
