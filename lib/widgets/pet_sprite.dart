import 'package:flutter/material.dart';

class PetSprite extends StatefulWidget {
  final bool isAlive;
  final bool isSleeping;
  final bool isAttacking;
  final bool isHurt;

  const PetSprite({
    super.key,
    required this.isAlive,
    this.isSleeping = false,
    this.isAttacking = false,
    this.isHurt = false,
  });

  @override
  State<PetSprite> createState() => _PetSpriteState();
}

class _PetSpriteState extends State<PetSprite> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -5.0, end: 5.0).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant PetSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isAlive) {
      _controller.stop();
    } else if (widget.isSleeping) {
      _controller.duration = const Duration(milliseconds: 1500);
      _controller.repeat(reverse: true);
    } else {
      _controller.duration = const Duration(milliseconds: 500);
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color petColor = widget.isAlive ? Colors.green : Colors.grey;
    if (widget.isHurt) petColor = Colors.red;
    if (widget.isAttacking) petColor = Colors.orange;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: widget.isAlive && !widget.isSleeping
              ? Offset(0, _animation.value)
              : const Offset(0, 0),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: petColor,
              border: Border.all(color: Colors.black, width: 4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                // Eyes
                Positioned(
                  top: 30,
                  left: 20,
                  child: _buildEye(),
                ),
                Positioned(
                  top: 30,
                  right: 20,
                  child: _buildEye(),
                ),
                // Mouth
                Positioned(
                  bottom: 20,
                  left: 30,
                  right: 30,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: widget.isAlive && !widget.isSleeping && !widget.isHurt
                          ? const BorderRadius.vertical(bottom: Radius.circular(10))
                          : BorderRadius.circular(0),
                    ),
                  ),
                ),
                if (widget.isSleeping)
                  const Positioned(
                    top: -20,
                    right: -10,
                    child: Text('Z', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
                  ),
                if (!widget.isAlive)
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.close, color: Colors.black, size: 40),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEye() {
    if (!widget.isAlive) {
      return const Text('X', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black, height: 1));
    }
    if (widget.isSleeping) {
      return Container(width: 15, height: 4, color: Colors.black);
    }
    if (widget.isHurt) {
      return const Text('>', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black, height: 1));
    }
    if (widget.isAttacking) {
      return Container(
        width: 15,
        height: 15,
        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.rectangle),
      );
    }
    return Container(
      width: 15,
      height: 15,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}
