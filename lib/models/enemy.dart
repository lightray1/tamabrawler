enum EnemyType { normal, fire, water, grass }

class Enemy {
  final String name;
  int hp;
  final int maxHp;
  final int attack;
  final int defense;
  final String spriteAsset;
  final EnemyType type;

  Enemy({
    required this.name,
    required this.hp,
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.spriteAsset,
    required this.type,
  });

  factory Enemy.slime({bool isBoss = false}) {
    return Enemy(
      name: isBoss ? 'Boss Slime' : 'Slime',
      hp: isBoss ? 60 : 30,
      maxHp: isBoss ? 60 : 30,
      attack: isBoss ? 10 : 5,
      defense: isBoss ? 4 : 2,
      spriteAsset: 'assets/images/enemy_slime.png',
      type: EnemyType.normal,
    );
  }

  factory Enemy.bat({bool isBoss = false}) {
    return Enemy(
      name: isBoss ? 'Boss Bat' : 'Bat',
      hp: isBoss ? 80 : 40,
      maxHp: isBoss ? 80 : 40,
      attack: isBoss ? 16 : 8,
      defense: isBoss ? 6 : 3,
      spriteAsset: 'assets/images/enemy_bat.png',
      type: EnemyType.normal,
    );
  }

  factory Enemy.goblin({bool isBoss = false}) {
    return Enemy(
      name: isBoss ? 'Boss Goblin' : 'Goblin',
      hp: isBoss ? 120 : 60,
      maxHp: isBoss ? 120 : 60,
      attack: isBoss ? 24 : 12,
      defense: isBoss ? 10 : 5,
      spriteAsset: 'assets/images/enemy_goblin.png',
      type: EnemyType.normal,
    );
  }
}
