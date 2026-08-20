import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/persistence.dart';
import '../services/sound_service.dart';
import '../widgets/pet_sprite.dart';
import '../widgets/stat_bar.dart';
import '../widgets/action_button.dart';

class HomeScreen extends StatefulWidget {
  final SoundService soundService;

  const HomeScreen({Key? key, required this.soundService}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PersistenceService _persistence = PersistenceService();
  Pet _pet = Pet();
  Timer? _timer;
  PetState _petState = PetState.idle;
  Timer? _stateResetTimer;

  @override
  void initState() {
    super.initState();
    _loadGame();
    _startTimer();
    widget.soundService.playBgm();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stateResetTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadGame() async {
    final loadedPet = await _persistence.loadPet();
    if (loadedPet != null) {
      setState(() {
        _pet = loadedPet;
        _pet.catchUp(); // Catch up on missed time
      });
      if (!_pet.isAlive) {
        _setPetState(PetState.dead);
      }
    }
  }

  void _saveGame() {
    _persistence.savePet(_pet);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _pet.tick();
      });
      if (!_pet.isAlive && _petState != PetState.dead) {
        _setPetState(PetState.dead);
        widget.soundService.playSfx('death');
      }
      // Save periodically or could just rely on state changes
      if (timer.tick % 10 == 0) {
        _saveGame();
      }
    });
  }

  void _setPetState(PetState state, {Duration duration = const Duration(seconds: 2)}) {
    if (_petState == PetState.dead && state != PetState.idle) return; // Only allow revive

    setState(() {
      _petState = state;
    });

    _stateResetTimer?.cancel();
    if (state != PetState.idle && state != PetState.dead) {
      _stateResetTimer = Timer(duration, () {
        if (mounted && _pet.isAlive) {
          setState(() {
            _petState = PetState.idle;
          });
        }
      });
    }
  }

  void _feed() {
    if (!_pet.isAlive) return;
    setState(() {
      _pet.hunger = min(100, _pet.hunger + 20);
      _pet.energy = max(0, _pet.energy - 5);
    });
    _setPetState(PetState.happy);
    widget.soundService.playSfx('eat');
    _saveGame();
  }

  void _play() {
    if (!_pet.isAlive) return;
    setState(() {
      _pet.happiness = min(100, _pet.happiness + 20);
      _pet.energy = max(0, _pet.energy - 10);
    });
    _setPetState(PetState.happy);
    // Placeholder minigame sound
    widget.soundService.playSfx('eat');
    _saveGame();
  }

  void _sleep() {
    if (!_pet.isAlive) return;
    setState(() {
      _pet.energy = min(100, _pet.energy + 30);
    });
    _setPetState(PetState.sleeping, duration: const Duration(seconds: 4));
    widget.soundService.playSfx('sleep');
    _saveGame();
  }

  void _heal() {
    if (!_pet.isAlive) return;
    setState(() {
      _pet.health = min(100, _pet.health + 30);
    });
    _setPetState(PetState.happy);
    // widget.soundService.playSfx('heal'); // heal not in spec, use eat as fallback or skip
    widget.soundService.playSfx('eat');
    _saveGame();
  }

  void _revive() {
    setState(() {
      _pet = Pet(); // Reset pet for now
      _setPetState(PetState.idle);
    });
    _saveGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3F51B5), Color(0xFF9C27B0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Sound Toggle
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: Icon(
                    widget.soundService.isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () async {
                    await widget.soundService.toggleMute();
                    setState(() {});
                  },
                ),
              ),
              // Level Indicator
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Level ${_pet.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 80),
                  // Pet Sprite Area
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: _pet.isAlive
                          ? PetSprite(state: _petState)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PetSprite(state: PetState.dead),
                                const SizedBox(height: 16),
                                const Text(
                                  'Your pet died.',
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                                ElevatedButton(
                                  onPressed: _revive,
                                  child: const Text('Revive'),
                                )
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stat Bars
                  Expanded(
                    child: Column(
                      children: [
                        StatBar(label: 'Hunger', value: _pet.hunger),
                        StatBar(label: 'Happiness', value: _pet.happiness),
                        StatBar(label: 'Energy', value: _pet.energy),
                        StatBar(label: 'Health', value: _pet.health),
                      ],
                    ),
                  ),
                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ActionButton(
                          iconPath: 'assets/images/icon_apple.png',
                          label: 'Feed',
                          onPressed: _feed,
                        ),
                        ActionButton(
                          iconPath: 'assets/images/icon_heart.png',
                          label: 'Play',
                          onPressed: _play,
                        ),
                        ActionButton(
                          iconPath: 'assets/images/icon_bed.png',
                          label: 'Sleep',
                          onPressed: _sleep,
                        ),
                        ActionButton(
                          iconPath: 'assets/images/icon_sword.png', // Or potion icon if we had one
                          label: 'Heal',
                          onPressed: _heal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Placeholder for Battle Arena
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Battle Arena coming soon!')),
          );
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.sports_martial_arts, color: Colors.white),
      ),
    );
  }
}
