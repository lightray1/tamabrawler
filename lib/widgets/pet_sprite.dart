import 'package:flutter/material.dart';
import '../models/pet.dart';

enum PetState { idle, sleeping, happy, attack, dead }

class PetSprite extends StatelessWidget {
  final PetState state;
  final PetStage? stage;

  const PetSprite({
    super.key,
    required this.state,
    this.stage,
  });

  String get _spriteAsset {
    // Note: Per spec, baby/teen/adult use the same base assets for now, but
    // teen uses 'pet_happy.png' with battle gear and adult uses 'pet_attack.png' with armor.
    // Since we only have the base assets, we map them accordingly, and add these comments
    // for future adult/teen specific sprites.

    switch (state) {
      case PetState.idle:
        if (stage == PetStage.teen) return 'assets/images/pet_happy.png'; // Future: teen idle sprite
        if (stage == PetStage.adult) return 'assets/images/pet_attack.png'; // Future: adult idle sprite
        return 'assets/images/pet_idle.png'; // Baby
      case PetState.sleeping:
        return 'assets/images/pet_sleep.png'; // All stages share sleep base for now
      case PetState.happy:
        return 'assets/images/pet_happy.png'; // All stages share happy base for now
      case PetState.attack:
        return 'assets/images/pet_attack.png'; // All stages share attack base for now
      case PetState.dead:
        return 'assets/images/pet_sleep.png'; // Gravestone placeholder
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
