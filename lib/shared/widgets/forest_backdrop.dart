import 'package:flutter/material.dart';

class ForestBackdrop extends StatelessWidget {
  const ForestBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF123D32),
            Color(0xFF1D5945),
            Color(0xFF287052),
            Color(0xFF102F29),
          ],
          stops: [0.0, 0.38, 0.72, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -100,
            right: -90,
            child: _GlowCircle(
              size: 280,
              color: Color(0xFF8CCB91),
            ),
          ),
          Positioned(
            bottom: -130,
            left: -100,
            child: _GlowCircle(
              size: 320,
              color: Color(0xFF75B78A),
            ),
          ),
          Positioned(
            top: 250,
            left: -120,
            child: _GlowCircle(
              size: 220,
              color: Color(0xFF4C9872),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.20),
              color.withValues(alpha: 0.07),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}