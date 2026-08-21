import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/enemy.dart';
import '../services/battle_engine.dart';
import '../services/battle_pve_service.dart';
import '../services/sound_service.dart';
import '../widgets/pet_sprite.dart';

class BattleScreen extends StatefulWidget {
  final Pet pet;
  final SoundService soundService;
  final Difficulty difficulty;

  const BattleScreen({
    super.key,
    required this.pet,
    required this.soundService,
    required this.difficulty,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with TickerProviderStateMixin {
  late PvEService pveService;
  late BattleEngine engine;
  late Enemy currentEnemy;

  bool _isProcessingTurn = false;
  bool _playerHit = false;
  bool _enemyHit = false;

  @override
  void initState() {
    super.initState();
    pveService = PvEService(difficulty: widget.difficulty);
    _initWave();
  }

  void _initWave() {
    currentEnemy = pveService.getCurrentEnemy();
    engine = BattleEngine(playerPet: widget.pet, enemy: currentEnemy);
    engine.log("A wild ${currentEnemy.name} appeared!");
  }

  void _onAction(BattleAction action) async {
    if (_isProcessingTurn) return;

    setState(() {
      _isProcessingTurn = true;
    });

    if (action == BattleAction.attack || action == BattleAction.special) {
      widget.soundService.playSfx('attack');
    }

    BattleAction enemyAction = engine.getEnemyAction();
    Map<String, dynamic> turnInfo = engine.executeTurn(action, enemyAction);

    String result = turnInfo['result'];
    int playerDamageTaken = turnInfo['playerDamageTaken'];
    int enemyDamageTaken = turnInfo['enemyDamageTaken'];

    setState(() {
      if (enemyDamageTaken > 0) _enemyHit = true;
      if (playerDamageTaken > 0) _playerHit = true;
    });

    if (_enemyHit || _playerHit) {
      widget.soundService.playSfx('hurt');
    }

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _enemyHit = false;
      _playerHit = false;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      _isProcessingTurn = false;
    });

    if (result == 'player_wins') {
      widget.soundService.playSfx('victory');
      bool isBoss = (pveService.currentWave == 5);
      pveService.onBattleVictory(widget.pet, isBoss);

      _showVictoryDialog(isBoss);
    } else if (result == 'enemy_wins') {
      widget.soundService.playSfx('death');
      pveService.onBattleDefeat(widget.pet);
      _showDefeatDialog();
    }
  }

  void _showVictoryDialog(bool isBoss) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Victory!'),
          content: Text(
            isBoss
              ? 'You beat the boss! Gained 100 XP.'
              : 'Enemy defeated! Gained 50 XP.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isBoss) {
                  Navigator.of(context).pop(true); // Return home
                } else {
                  pveService.onWaveComplete(widget.pet);
                  setState(() {
                    _initWave();
                  });
                }
              },
              child: Text(isBoss ? 'Finish' : 'Next Wave'),
            ),
          ],
        );
      }
    );
  }

  void _showDefeatDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Defeat!'),
          content: const Text('Your pet fainted!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(false); // Return home
              },
              child: const Text('Revive pet?'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            // Enemy area
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${currentEnemy.name} (Wave ${pveService.currentWave}/5)",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      value: currentEnemy.hp / currentEnemy.maxHp,
                      color: Colors.red,
                      backgroundColor: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: _enemyHit ? 0.0 : 1.0),
                    duration: const Duration(milliseconds: 100),
                    builder: (context, val, child) {
                      return ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.red.withValues(alpha: 1 - val),
                          BlendMode.srcATop
                        ),
                        child: Transform.translate(
                          offset: Offset(0, _enemyHit ? -10 : 0),
                          child: Image.asset(
                            currentEnemy.spriteAsset,
                            width: 128,
                            height: 128,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Actions area
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: const Border(
                  top: BorderSide(color: Colors.white24, width: 2),
                  bottom: BorderSide(color: Colors.white24, width: 2),
                )
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      itemCount: engine.battleLog.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                          child: Text(
                            engine.battleLog[index],
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _isProcessingTurn ? null : () => _onAction(BattleAction.attack),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                          child: const Text('Attack'),
                        ),
                        ElevatedButton(
                          onPressed: _isProcessingTurn ? null : () => _onAction(BattleAction.defend),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                          child: const Text('Defend'),
                        ),
                        ElevatedButton(
                          onPressed: (_isProcessingTurn || widget.pet.energy < 15)
                              ? null
                              : () => _onAction(BattleAction.special),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700]),
                          child: const Text('Special (-15 NRG)'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Player area
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: _playerHit ? 0.0 : 1.0),
                    duration: const Duration(milliseconds: 100),
                    builder: (context, val, child) {
                      return ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.red.withValues(alpha: 1 - val),
                          BlendMode.srcATop
                        ),
                        child: Transform.translate(
                          offset: Offset(0, _playerHit ? 10 : 0),
                          child: Transform.scale(
                            scale: 2.0, // Scale 64x64 to 128x128 approx
                            child: PetSprite(state: PetState.idle),
                          )
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.pet.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      value: widget.pet.health / 100,
                      color: Colors.green,
                      backgroundColor: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "HP: ${widget.pet.health}/100 | NRG: ${widget.pet.energy}/100",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
