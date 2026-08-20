import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

class Pet extends ChangeNotifier {
  String name;
  double hunger;
  double energy;
  double happiness;
  double health;
  bool isAlive;
  bool isSleeping;
  Timer? _decayTimer;

  Pet({
    this.name = 'Tamabrawler',
    this.hunger = 100.0,
    this.energy = 100.0,
    this.happiness = 100.0,
    this.health = 100.0,
    this.isAlive = true,
    this.isSleeping = false,
  }) {
    _startDecay();
  }

  void _startDecay() {
    _decayTimer?.cancel();
    _decayTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!isAlive) {
        timer.cancel();
        return;
      }

      if (!isSleeping) {
        hunger = max(0.0, hunger - 1.0);
        energy = max(0.0, energy - 0.5);
        happiness = max(0.0, happiness - 0.8);
      } else {
        hunger = max(0.0, hunger - 0.5);
        energy = min(100.0, energy + 2.0);
      }

      if (hunger == 0 || energy == 0 || happiness == 0) {
        health = max(0.0, health - 2.0);
      } else {
        if (!isSleeping && health < 100) {
           health = min(100.0, health + 0.5);
        }
      }

      if (health == 0) {
        isAlive = false;
        isSleeping = false;
      }

      notifyListeners();
    });
  }

  void feed() {
    if (!isAlive || isSleeping) return;
    hunger = min(100.0, hunger + 20.0);
    health = min(100.0, health + 5.0);
    notifyListeners();
  }

  void play() {
    if (!isAlive || isSleeping) return;
    happiness = min(100.0, happiness + 20.0);
    energy = max(0.0, energy - 10.0);
    hunger = max(0.0, hunger - 10.0);
    notifyListeners();
  }

  void toggleSleep() {
    if (!isAlive) return;
    isSleeping = !isSleeping;
    notifyListeners();
  }

  void takeDamage(double amount) {
    if (!isAlive) return;
    health = max(0.0, health - amount);
    if (health == 0) {
      isAlive = false;
    }
    notifyListeners();
  }

  double get attackDamage => 10.0 + (happiness / 10.0) + (energy / 10.0);

  void revive() {
    isAlive = true;
    health = 100.0;
    hunger = 100.0;
    energy = 100.0;
    happiness = 100.0;
    isSleeping = false;
    _startDecay();
    notifyListeners();
  }

  @override
  void dispose() {
    _decayTimer?.cancel();
    super.dispose();
  }
}
