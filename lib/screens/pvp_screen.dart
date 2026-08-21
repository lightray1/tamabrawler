import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/sound_service.dart';
import '../services/battle_engine.dart'; // For BattleAction
import '../services/pvp_battle_engine.dart';
import '../widgets/pet_sprite.dart';

class PvPScreen extends StatefulWidget {
  final Pet player1Pet;
  final Pet player2Pet;
  final SoundService soundService;

  const PvPScreen({
    super.key,
    required this.player1Pet,
    required this.player2Pet,
    required this.soundService,
  });

  @override
  State<PvPScreen> createState() => _PvPScreenState();
}

class _PvPScreenState extends State<PvPScreen> {
  late PvPBattleEngine engine;

  bool _isProcessingTurn = false;
  bool _p1Hit = false;
  bool _p2Hit = false;

  int _currentPlayerTurn = 1;
  BattleAction? _p1Action;

  @override
  void initState() {
    super.initState();
    engine = PvPBattleEngine(player1: widget.player1Pet, player2: widget.player2Pet);
    engine.log("PvP Battle started!");
  }

  void _onAction(BattleAction action) async {
    if (_isProcessingTurn) return;

    if (_currentPlayerTurn == 1) {
      setState(() {
        _p1Action = action;
        _currentPlayerTurn = 2;
      });
      return;
    }

    // Player 2 selected an action, execute turn
    setState(() {
      _isProcessingTurn = true;
    });

    if (_p1Action == BattleAction.attack || _p1Action == BattleAction.special ||
        action == BattleAction.attack || action == BattleAction.special) {
      widget.soundService.playSfx('attack');
    }

    Map<String, dynamic> turnInfo = engine.executeTurn(_p1Action!, action);

    String result = turnInfo['result'];
    int p1DamageTaken = turnInfo['p1DamageTaken'];
    int p2DamageTaken = turnInfo['p2DamageTaken'];

    setState(() {
      if (p1DamageTaken > 0) _p1Hit = true;
      if (p2DamageTaken > 0) _p2Hit = true;
    });

    if (_p1Hit || _p2Hit) {
      widget.soundService.playSfx('hurt');
    }

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _p1Hit = false;
      _p2Hit = false;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      _p1Action = null;
      _currentPlayerTurn = 1;
      _isProcessingTurn = false;
    });

    if (result == 'player1_wins') {
      widget.soundService.playSfx('victory');
      widget.player1Pet.wins++;
      widget.player1Pet.levelUp(100);
      widget.player2Pet.losses++;
      widget.player2Pet.levelUp(20);
      _showResultDialog('Player 1 Wins!', widget.player1Pet.name, 100, widget.player2Pet.name, 20);
    } else if (result == 'player2_wins') {
      widget.soundService.playSfx('victory'); // Player 2 won, still a victory sound
      widget.player2Pet.wins++;
      widget.player2Pet.levelUp(100);
      widget.player1Pet.losses++;
      widget.player1Pet.levelUp(20);
      _showResultDialog('Player 2 Wins!', widget.player2Pet.name, 100, widget.player1Pet.name, 20);
    }
  }

  void _showResultDialog(String title, String winnerName, int winnerXp, String loserName, int loserXp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$winnerName gains $winnerXp XP!'),
              Text('$loserName gains $loserXp XP.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true); // Return home indicating battle ended
              },
              child: const Text('Finish'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    Pet activePet = _currentPlayerTurn == 1 ? widget.player1Pet : widget.player2Pet;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            // Player 2 Area (Top) - Rotated 180 degrees so Player 2 can face it from across
            Expanded(
              flex: 2,
              child: RotatedBox(
                quarterTurns: 2, // Upside down for hot-seat comfort
                child: _buildPlayerArea(widget.player2Pet, _p2Hit, 'Player 2'),
              ),
            ),

            // Actions / HUD Area (Middle)
            Container(
              height: 200, // Slightly taller for more log info + turn indicator
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: const Border(
                  top: BorderSide(color: Colors.white24, width: 2),
                  bottom: BorderSide(color: Colors.white24, width: 2),
                )
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: _currentPlayerTurn == 1 ? Colors.blue.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      "Player $_currentPlayerTurn's Turn",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
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
                          onPressed: (_isProcessingTurn || activePet.energy < 15)
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

            // Player 1 Area (Bottom)
            Expanded(
              flex: 2,
              child: _buildPlayerArea(widget.player1Pet, _p1Hit, 'Player 1'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerArea(Pet pet, bool isHit, String playerLabel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: isHit ? 0.0 : 1.0),
          duration: const Duration(milliseconds: 100),
          builder: (context, val, child) {
            return ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.red.withValues(alpha: 1 - val),
                BlendMode.srcATop
              ),
              child: Transform.translate(
                offset: Offset(0, isHit ? 10 : 0), // Simple bounce down
                child: Transform.scale(
                  scale: 2.0, // Scale 64x64 to 128x128
                  child: PetSprite(state: PetState.idle, stage: pet.stage),
                )
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          "$playerLabel: ${pet.name}",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            value: pet.health / pet.getMaxStat(),
            color: Colors.green,
            backgroundColor: Colors.green.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "HP: ${pet.health}/${pet.getMaxStat()} | NRG: ${pet.energy}/${pet.getMaxStat()}",
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
