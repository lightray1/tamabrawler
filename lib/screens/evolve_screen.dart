import 'dart:math';
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../widgets/pet_sprite.dart';
import '../services/sound_service.dart';

class EvolveScreen extends StatefulWidget {
  final Pet pet;
  final SoundService soundService;

  const EvolveScreen({super.key, required this.pet, required this.soundService});

  @override
  State<EvolveScreen> createState() => _EvolveScreenState();
}

class _EvolveScreenState extends State<EvolveScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    widget.soundService.playSfx('victory');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          // Sparkle background
          Positioned.fill(
            child: CustomPaint(
              painter: SparklePainter(animation: _controller),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: PetSprite(state: PetState.idle, stage: widget.pet.stage),
                ),
                const SizedBox(height: 60),
                Text(
                  "${widget.pet.name} evolved into ${widget.pet.getStageName()}!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "New Stat Caps: ${widget.pet.getMaxStat()}",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SparklePainter extends CustomPainter {
  final Animation<double> animation;
  final Random _random = Random(42); // Fixed seed for stable layout
  late List<Offset> _sparkles;

  SparklePainter({required this.animation}) : super(repaint: animation) {
    _sparkles = List.generate(50, (index) {
      return Offset(_random.nextDouble(), _random.nextDouble());
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.8 * (1.0 - animation.value));

    for (var normalizedPos in _sparkles) {
      final pos = Offset(
        normalizedPos.dx * size.width,
        normalizedPos.dy * size.height,
      );
      // Explode outwards based on animation
      final center = Offset(size.width / 2, size.height / 2);
      final direction = pos - center;
      final currentPos = center + direction * (1.0 + animation.value * 2);

      canvas.drawCircle(currentPos, _random.nextDouble() * 3 + 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
