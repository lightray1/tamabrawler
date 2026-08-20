import 'dart:math';
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../widgets/pet_sprite.dart';
import '../widgets/stat_bar.dart';
import '../widgets/pixel_button.dart';

class CombatScreen extends StatefulWidget {
  final Pet playerPet;
  final bool isPvP;

  const CombatScreen({
    super.key,
    required this.playerPet,
    required this.isPvP,
  });

  @override
  State<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends State<CombatScreen> {
  late Pet opponentPet;
  bool isPlayerTurn = true;
  String combatLog = "FIGHT BEGINS!";

  @override
  void initState() {
    super.initState();
    if (widget.isPvP) {
      opponentPet = Pet(name: 'Player 2');
    } else {
      opponentPet = Pet(name: 'Monster', hunger: 50, happiness: 50, energy: 100);
    }
  }

  void _attack(Pet attacker, Pet defender) {
    if (!attacker.isAlive || !defender.isAlive) return;

    double damage = attacker.attackDamage + Random().nextInt(10);
    defender.takeDamage(damage);

    setState(() {
      combatLog = "${attacker.name} attacked ${defender.name} for ${damage.toInt()} damage!";

      if (!defender.isAlive) {
        combatLog = "${defender.name} FAINTED! ${attacker.name} WINS!";
      } else {
        isPlayerTurn = !isPlayerTurn;
        if (!widget.isPvP && !isPlayerTurn) {
          // AI turn
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted && opponentPet.isAlive) {
              _attack(opponentPet, widget.playerPet);
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('BATTLE', style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Opponent
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[300],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(opponentPet.name, style: const TextStyle(fontFamily: 'Courier', fontSize: 20, fontWeight: FontWeight.bold)),
                    StatBar(label: 'HP', value: opponentPet.health, color: Colors.red),
                    const SizedBox(height: 10),
                    PetSprite(
                      isAlive: opponentPet.isAlive,
                      isHurt: !opponentPet.isAlive || (!isPlayerTurn && opponentPet.isAlive && widget.isPvP),
                    ),
                    if (widget.isPvP && !isPlayerTurn && opponentPet.isAlive && widget.playerPet.isAlive)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: PixelButton(
                          text: 'ATTACK',
                          color: Colors.red,
                          onPressed: () => _attack(opponentPet, widget.playerPet),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Log
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.black,
              child: Text(
                combatLog,
                style: const TextStyle(fontFamily: 'Courier', color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),

            // Player
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.amber[100],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isPlayerTurn && widget.playerPet.isAlive && opponentPet.isAlive)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PixelButton(
                          text: 'ATTACK',
                          color: Colors.blue,
                          onPressed: () => _attack(widget.playerPet, opponentPet),
                        ),
                      ),
                    PetSprite(
                      isAlive: widget.playerPet.isAlive,
                      isHurt: !widget.playerPet.isAlive,
                    ),
                    const SizedBox(height: 10),
                    StatBar(label: 'HP', value: widget.playerPet.health, color: Colors.red),
                    Text(widget.playerPet.name, style: const TextStyle(fontFamily: 'Courier', fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
