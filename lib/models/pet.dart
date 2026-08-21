import 'dart:math';

enum PetStage { baby, teen, adult }

class Pet {
  String name;
  int hunger;
  int happiness;
  int energy;
  int health;
  int level;
  int xp;
  PetStage stage;
  int wins;
  int losses;
  bool isAlive;
  DateTime lastUpdated;

  int _hungerTimer = 0;
  int _happinessTimer = 0;
  int _energyTimer = 0;
  int _healthTimer = 0;

  int get battleAttack => level * 2 + (happiness ~/ 5);
  int get battleDefense => (level * 1.5).floor() + (energy ~/ 5);
  int get battleSpeed => (happiness ~/ 5) + (energy ~/ 5);

  int getMaxStat() {
    switch (stage) {
      case PetStage.baby: return 100;
      case PetStage.teen: return 150;
      case PetStage.adult: return 200;
    }
  }

  String getStageName() {
    switch (stage) {
      case PetStage.baby: return 'Baby';
      case PetStage.teen: return 'Teen';
      case PetStage.adult: return 'Adult';
    }
  }

  bool checkEvolution() {
    PetStage oldStage = stage;
    if (level >= 16) {
      stage = PetStage.adult;
    } else if (level >= 6) {
      stage = PetStage.teen;
    } else {
      stage = PetStage.baby;
    }
    return oldStage != stage;
  }

  bool _pendingEvolution = false;
  bool get pendingEvolution => _pendingEvolution;

  void clearEvolutionPending() {
    _pendingEvolution = false;
  }

  bool levelUp(int gainedXp) {
    xp += gainedXp;
    bool evolved = false;

    while (xp >= level * 100 && level < 30) {
      xp -= level * 100;
      level++;

      int oldMax = getMaxStat();
      if (checkEvolution()) {
        evolved = true;
        _pendingEvolution = true;
        int newMax = getMaxStat();

        // Scale stats proportionally
        hunger = (hunger * newMax) ~/ oldMax;
        happiness = (happiness * newMax) ~/ oldMax;
        energy = (energy * newMax) ~/ oldMax;
        health = (health * newMax) ~/ oldMax;
      }
    }
    // Cap XP if max level
    if (level >= 30) {
      level = 30;
      xp = 0;
    }
    return evolved;
  }

  Pet({
    this.name = 'Tamabrawler',
    this.hunger = 70,
    this.happiness = 70,
    this.energy = 70,
    this.health = 70,
    this.level = 1,
    this.xp = 0,
    this.stage = PetStage.baby,
    this.wins = 0,
    this.losses = 0,
    this.isAlive = true,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory Pet.fromJson(Map<String, dynamic> json) {
    var pet = Pet(
      name: json['name'] as String? ?? 'Tamabrawler',
      hunger: json['hunger'] as int? ?? 70,
      happiness: json['happiness'] as int? ?? 70,
      energy: json['energy'] as int? ?? 70,
      health: json['health'] as int? ?? 70,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      stage: PetStage.values.firstWhere(
        (e) => e.name == (json['stage'] as String? ?? 'baby'),
        orElse: () => PetStage.baby,
      ),
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      isAlive: json['isAlive'] as bool? ?? true,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated']) ?? DateTime.now()
          : DateTime.now(),
    );

    pet._hungerTimer = json['hungerTimer'] as int? ?? 0;
    pet._happinessTimer = json['happinessTimer'] as int? ?? 0;
    pet._energyTimer = json['energyTimer'] as int? ?? 0;
    pet._healthTimer = json['healthTimer'] as int? ?? 0;

    return pet;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hunger': hunger,
      'happiness': happiness,
      'energy': energy,
      'health': health,
      'level': level,
      'xp': xp,
      'stage': stage.name,
      'wins': wins,
      'losses': losses,
      'isAlive': isAlive,
      'lastUpdated': lastUpdated.toIso8601String(),
      'hungerTimer': _hungerTimer,
      'happinessTimer': _happinessTimer,
      'energyTimer': _energyTimer,
      'healthTimer': _healthTimer,
    };
  }

  void catchUp() {
    final now = DateTime.now();
    final secondsPassed = now.difference(lastUpdated).inSeconds;
    if (secondsPassed > 0) {
      // Limit catchUp to a maximum of 3 days to avoid performance issues if left unplayed for long
      final maxSeconds = min(secondsPassed, 3 * 24 * 60 * 60);
      for (int i = 0; i < maxSeconds; i++) {
        tick();
      }
      lastUpdated = now;
    }
  }

  void tick() {
    if (!isAlive) return;

    _hungerTimer++;
    _happinessTimer++;
    _energyTimer++;

    if (hunger == 0) {
      _healthTimer++;
    } else {
      _healthTimer = 0;
    }

    if (_hungerTimer >= 30) {
      hunger = max(0, hunger - 1);
      _hungerTimer = 0;
    }
    if (_happinessTimer >= 45) {
      happiness = max(0, happiness - 1);
      _happinessTimer = 0;
    }
    if (_energyTimer >= 60) {
      energy = max(0, energy - 1);
      _energyTimer = 0;
    }
    if (_healthTimer >= 120) {
      health = max(0, health - 1);
      _healthTimer = 0;
      if (health == 0) {
        isAlive = false;
      }
    }
  }
}
