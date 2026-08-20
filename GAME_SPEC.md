# Tamabrawler — Game Specification

## Concept
A tamagotchi-style pet raising game where you care for a cute creature and train it for turn-based battles against wild monsters (PvE) or friends' pets (PvP hot-seat).

## Art Style
- 8-bit pixel art inspired by PICO-8 palette (16 colors), using sprites in `assets/images/`
- All sprite files are 16x16 upscaled 4× to 64×64 PNGs
- Icons are 8x8 upscaled 2× to 16×16
- UI uses Material 3 with a retro color scheme (dark background, bright accents)

## Audio
- 8-bit chiptune style WAV files in `assets/audio/` (22050Hz, 8-bit mono)
- Sound effects loaded via `audioplayers` package
- Background music loop for main screen

## Architecture

### File Structure
```
lib/
  main.dart              — App entry point
  models/
    pet.dart             — Pet data model (+ stats, evolution)
    enemy.dart           — Enemy model
    battle.dart          — Battle state machine
  screens/
    home_screen.dart     — Main pet interaction screen
    battle_screen.dart   — Combat arena (PvE & PvP)
    evolve_screen.dart   — Evolution animation screen
  widgets/
    pet_sprite.dart      — Animated pet sprite widget
    stat_bar.dart        — Reusable stat bar (hunger/happiness/energy/health)
    action_button.dart   — Icon button for care actions
    battle_hud.dart      — Battle UI (HP bars, action buttons)
  services/
    sound_service.dart   — Audio playback (bgm + SFX)
    persistence.dart     — Save/load game state via SharedPreferences
    battle_engine.dart   — Battle logic (damage calc, AI moves)
```

### Data Flow
- Game state is a singleton `GameState` ChangeNotifier
- Serialized to JSON via SharedPreferences on every state change
- Pet stats tick down via a Timer every few seconds when app is active
- Audio service initializes on app start, plays BGM loop on main screen

## Pet System

### Pet Model (`lib/models/pet.dart`)
```dart
class Pet {
  String name;
  int hunger;       // 0-100
  int happiness;    // 0-100
  int energy;       // 0-100
  int health;       // 0-100
  int level;        // 1-30
  int xp;           // 0 to next level
  PetStage stage;   // baby, teen, adult
  int wins;         // PvP wins
  int losses;       // battles lost
  bool isAlive;
}
```

### Pet Stages (Evolution)
- **Baby** (lvl 1-5): Small, round, more needy → sprite: `pet_idle.png`
- **Teen** (lvl 6-15): Medium size, starts battle training → sprite: `pet_happy.png` with battle gear
- **Adult** (lvl 16-30): Full size, maximum stats → sprite: `pet_attack.png` with armor

At evolution, show a brief animation screen.

### Stat Mechanics
- All stats start at 70 (new game)
- **Hunger**: -1 every 30 seconds. When 0: -2 health/30s.
- **Happiness**: -1 every 45 seconds. When 0: energy regen halved.
- **Energy**: -1 every 60 seconds. Battles cost 15 energy. 0 = can't battle.
- **Health**: -1 every 120 seconds when hunger=0. Battles cost HP.
- If health reaches 0: pet dies (isAlive=false, gravestone screen with "Revive?" button).

### Care Actions (Home Screen)
1. **Feed** (+20 hunger, -5 energy) → plays `eat.wav`, shows pet eating animation
2. **Play** (+20 happiness, -10 energy) → mini-game (tap pet 5 times in 5 seconds)
3. **Sleep** (+30 energy, -5 hunger while awake time passes) → plays `sleep.wav`, shows sleeping sprite
4. **Heal** (+30 health, uses 1 "Potion" item if available)

Each action has a 3-second cooldown before the next action.

## Battle System

### Battle Engine (`lib/services/battle_engine.dart`)
Turn-based, with each side taking turns:

1. Player selects action: **Attack**, **Defend**, **Special**
2. Enemy AI picks action (weighted random)
3. Damage is calculated and applied
4. Results displayed with animation
5. Repeat until one side's HP reaches 0

### Stats in Battle
- **HP**: = health stat (0-100)
- **Attack Power**: = level × 2 + happiness/5
- **Defense**: = level × 1.5 + energy/5
- **Speed**: = happiness/5 + energy/5 (who goes first)

### Actions
| Action | Effect | Description |
|--------|--------|-------------|
| Attack | DMG = atk - def/2 (min 1) | Basic hit, plays `attack.wav` |
| Defend | +50% def for 1 turn | Blocks more damage next turn |
| Special | DMG = atk × 2 (costs 15 energy) | Powerful but drains energy |

### Enemy AI Logic
- 50% chance to **Attack**
- 25% chance to **Defend** (if HP < 30%)
- 15% chance to **Special** (if energy > 0)
- 10% chance to **Heal** (heals 15 HP, if HP < 50%)

### PvE (Arena Mode)
- Single player chooses difficulty: Easy / Medium / Hard
- Each difficulty has 5 waves of increasing enemy strength
- Between waves: pet recovers 10% HP
- Final wave = boss fight (enemy with 2× HP)
- Victory: +50 XP + random item drop
- Defeat: pet faints, no XP, health drops to 10

### PvP (Hot-Seat Mode)
- Two players share the same device
- Player 1 sets up Pet A, Player 2 sets up Pet B
- Standard battle, alternating turns
- Winner: +100 XP, +1 win stat
- Loser: +20 XP, +1 loss stat

## Enemy Types (`lib/models/enemy.dart`)
```dart
class Enemy {
  String name;
  int hp;
  int attack;
  int defense;
  String spriteAsset;  // e.g. 'assets/images/enemy_slime.png'
  BattleType type;     // normal, fire, water, grass
}
```

| Enemy | Sprite | Difficulty | HP | Notes |
|-------|--------|------------|----|-------|
| Slime | `enemy_slime.png` | Easy | 20-40 | Low damage, intro enemy |
| Bat | `enemy_bat.png` | Medium | 30-50 | Fast, dodges sometimes |
| Goblin | `enemy_goblin.png` | Hard | 40-70 | Strong attacks, boss material |

## UI Screens

### 1. Home Screen
- **Background**: Dark gradient (indigo to purple)
- **Pet display**: Center area showing the current pet sprite (animated idle)
- **Stat bars**: Below pet, 4 bars for hunger/happiness/energy/health
- **Level indicator**: Top-right, shows level + XP bar
- **Action buttons**: Bottom row of 4 icon buttons:
  - 🍎 Feed | 😄 Play | 💤 Sleep | 💊 Heal
- **Battle Arena button**: Bottom-right floating button
- **Sound toggle**: Top-left speaker icon
- Actions trigger animations and stat changes with a 3s cooldown

### 2. Battle Screen
- **Top**: Enemy name + HP bar (top), Enemy sprite
- **Middle**: Action buttons (Attack | Defend | Special)
- **Bottom**: Player's pet name + HP bar, Pet sprite
- **Battle log**: Scrollable text showing last 5 actions
- Animations: sprites bounce on hit, flash red when damaged
- PvP mode: shows "Player 1 / Player 2" turn indicator

### 3. Evolution Screen
- Pet sprite grows larger with sparkle particle effect
- Text: "Your pet evolved!"
- New stats preview (higher caps)
- Auto-closes after 3 seconds

## Persistence (`lib/services/persistence.dart`)
- Save game state as JSON using SharedPreferences
- Save on: stat change, level up, after battle
- Load on: app start
- Key: `tamabrawler_save`

## Sound Service (`lib/services/sound_service.dart`)
- Uses `audioplayers` package
- Preloads all WAV files on init
- BGM loop: `bgm_loop.wav` plays on home screen
- SFX: trigger per action/battle event
- Mute toggle persists in SharedPreferences

## Implementation Phases

### Phase 1 — Core Pet & Home Screen
- Set up Flutter project with folder structure
- Create `Pet` model with all stats and decay timer
- Build `home_screen.dart` with stat bars, action buttons
- Create `stat_bar.dart` and `action_button.dart` widgets
- Implement Feed/Play/Sleep/Heal actions with stat changes
- Display static pet sprite on screen
- Add `persistence.dart` for save/load
- Audio: integrate `audioplayers`, play `eat.wav`, `sleep.wav` on actions

### Phase 2 — Battle System (PvE)
- Create `Enemy` model with enemy types and data
- Implement `battle_engine.dart` turn-based combat
- Build `battle_screen.dart` with HUD and action buttons
- Add PvE matchmaking (wave system: 5 waves per difficulty)
- Enemy AI decision logic
- After-battle: XP gain, item drops, stat recovery
- Sound: `attack.wav`, `victory.wav`, `death.wav`

### Phase 3 — PvP & Evolution
- Hot-seat PvP: two pets loaded from saved profiles
- Alternating turns with visual turn indicator
- Evolution system: level-based thresholds
- `evolve_screen.dart` animation
- Stats cap increase per stage
- Pet sprite swap per stage

### Phase 4 — Polish
- Animations: bounce, flash, fade on actions
- BGM loop on home screen
- Pet death screen with revive option
- Visual feedback: stat bars animate when changed
- Mini-game for "Play" action (tap pet rapidly)
- Edge cases: death recovery, battle withdrawal, cooldown enforcement
- Retrieve current assets from `assets/` (images + audio) and reference them properly in the code

## Asset Inventory
| Asset | Path | Type | Size |
|-------|------|------|------|
| pet_idle.png | assets/images/pet_idle.png | Sprite | 64×64 |
| pet_happy.png | assets/images/pet_happy.png | Sprite | 64×64 |
| pet_sleep.png | assets/images/pet_sleep.png | Sprite | 64×64 |
| pet_attack.png | assets/images/pet_attack.png | Sprite | 64×64 |
| enemy_slime.png | assets/images/enemy_slime.png | Sprite | 64×64 |
| enemy_bat.png | assets/images/enemy_bat.png | Sprite | 64×64 |
| enemy_goblin.png | assets/images/enemy_goblin.png | Sprite | 64×64 |
| icon_heart.png | assets/images/icon_heart.png | Icon | 16×16 |
| icon_apple.png | assets/images/icon_apple.png | Icon | 16×16 |
| icon_bed.png | assets/images/icon_bed.png | Icon | 16×16 |
| icon_sword.png | assets/images/icon_sword.png | Icon | 16×16 |
| eat.wav | assets/audio/eat.wav | SFX | ~2KB |
| sleep.wav | assets/audio/sleep.wav | SFX | ~2KB |
| hurt.wav | assets/audio/hurt.wav | SFX | ~2KB |
| attack.wav | assets/audio/attack.wav | SFX | ~2KB |
| victory.wav | assets/audio/victory.wav | SFX | ~2KB |
| death.wav | assets/audio/death.wav | SFX | ~2KB |
| bgm_loop.wav | assets/audio/bgm_loop.wav | BGM | ~18KB |