import 'package:flutter/material.dart';

enum PetState { idle, sleeping, happy, attack, dead }

class PetSprite extends StatelessWidget {
  final PetState state;

  const PetSprite({
    Key? key,
    required this.state,
  }) : super(key: key);

  String get _spriteAsset {
    switch (state) {
      case PetState.idle:
        return 'assets/images/pet_idle.png';
      case PetState.sleeping:
        return 'assets/images/pet_sleep.png';
      case PetState.happy:
        return 'assets/images/pet_happy.png';
      case PetState.attack:
        return 'assets/images/pet_attack.png';
      case PetState.dead:
        // Placeholder, the spec says "gravestone screen", we might use sleeping or idle for now
        // if no dead sprite is specified, although we only have idle, happy, sleep, attack
        return 'assets/images/pet_sleep.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _spriteAsset,
      width: 128,
      height: 128,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none, // To keep pixel art sharp
    );
  }
}
