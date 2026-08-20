import 'package:flutter/material.dart';

class ActionButton extends StatefulWidget {
  final String iconPath;
  final String label;
  final VoidCallback onPressed;
  final Duration cooldown;

  const ActionButton({
    Key? key,
    required this.iconPath,
    required this.label,
    required this.onPressed,
    this.cooldown = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> with SingleTickerProviderStateMixin {
  bool _isOnCooldown = false;
  late AnimationController _cooldownController;

  @override
  void initState() {
    super.initState();
    _cooldownController = AnimationController(
      vsync: this,
      duration: widget.cooldown,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isOnCooldown = false;
          });
        }
      });
  }

  @override
  void dispose() {
    _cooldownController.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (!_isOnCooldown) {
      setState(() {
        _isOnCooldown = true;
      });
      _cooldownController.forward(from: 0.0);
      widget.onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _handlePress,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    widget.iconPath,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              if (_isOnCooldown)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _cooldownController,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CustomPaint(
                          painter: CooldownPainter(
                            progress: 1.0 - _cooldownController.value,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class CooldownPainter extends CustomPainter {
  final double progress;

  CooldownPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // Draw a rectangle representing the remaining cooldown filling from bottom to top
    final rect = Rect.fromLTRB(
      0,
      size.height * (1.0 - progress),
      size.width,
      size.height,
    );
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CooldownPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
