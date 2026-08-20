import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../widgets/stat_bar.dart';
import '../widgets/pet_sprite.dart';
import '../widgets/pixel_button.dart';
import 'combat_screen.dart';

class HomeScreen extends StatefulWidget {
  final Pet pet;
  const HomeScreen({super.key, required this.pet});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.pet.addListener(_update);
  }

  @override
  void dispose() {
    widget.pet.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  void _startCombat(bool isPvP) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CombatScreen(
          playerPet: widget.pet,
          isPvP: isPvP,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
      appBar: AppBar(
        title: Text(widget.pet.name, style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 4),
                ),
                child: Column(
                  children: [
                    StatBar(label: 'HEALTH', value: widget.pet.health, color: Colors.red),
                    StatBar(label: 'HUNGER', value: widget.pet.hunger, color: Colors.orange),
                    StatBar(label: 'ENERGY', value: widget.pet.energy, color: Colors.blue),
                    StatBar(label: 'HAPPY', value: widget.pet.happiness, color: Colors.pink),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: PetSprite(
                  isAlive: widget.pet.isAlive,
                  isSleeping: widget.pet.isSleeping,
                ),
              ),
              if (!widget.pet.isAlive)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: PixelButton(
                    text: 'REVIVE',
                    color: Colors.green,
                    onPressed: widget.pet.revive,
                  ),
                ),
              const Spacer(),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  PixelButton(
                    text: 'FEED',
                    color: Colors.orange,
                    onPressed: widget.pet.feed,
                  ),
                  PixelButton(
                    text: 'PLAY',
                    color: Colors.pink,
                    onPressed: widget.pet.play,
                  ),
                  PixelButton(
                    text: widget.pet.isSleeping ? 'WAKE' : 'SLEEP',
                    color: Colors.blue,
                    onPressed: widget.pet.toggleSleep,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.black, thickness: 2),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PixelButton(
                    text: 'PVE BATTLE',
                    color: Colors.purple,
                    onPressed: widget.pet.isAlive && !widget.pet.isSleeping ? () => _startCombat(false) : () {},
                  ),
                  PixelButton(
                    text: 'PVP BATTLE',
                    color: Colors.deepPurple,
                    onPressed: widget.pet.isAlive && !widget.pet.isSleeping ? () => _startCombat(true) : () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
