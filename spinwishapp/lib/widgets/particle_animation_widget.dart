import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double opacity;
  double life;
  double maxLife;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.opacity,
    required this.life,
    required this.maxLife,
  });

  void update() {
    x += vx;
    y += vy;
    life -= 1;
    opacity = (life / maxLife).clamp(0.0, 1.0);
  }

  bool get isDead => life <= 0;
}

class ParticleAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Color particleColor;
  final int particleCount;
  final double particleSize;
  final Duration animationDuration;

  const ParticleAnimationWidget({
    super.key,
    required this.child,
    this.enabled = true,
    this.particleColor = Colors.white,
    this.particleCount = 50,
    this.particleSize = 2.0,
    this.animationDuration = const Duration(milliseconds: 16),
  });

  @override
  State<ParticleAnimationWidget> createState() =>
      _ParticleAnimationWidgetState();
}

class _ParticleAnimationWidgetState extends State<ParticleAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    if (widget.enabled) {
      _controller.repeat();
      _controller.addListener(_updateParticles);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateParticles() {
    if (_size == Size.zero) return;

    setState(() {
      // Update existing particles
      _particles.removeWhere((particle) {
        particle.update();
        return particle.isDead;
      });

      // Add new particles if needed
      while (_particles.length < widget.particleCount) {
        _particles.add(_createParticle());
      }
    });
  }

  Particle _createParticle() {
    return Particle(
      x: _random.nextDouble() * _size.width,
      y: _size.height + 10,
      vx: (_random.nextDouble() - 0.5) * 2,
      vy: -_random.nextDouble() * 3 - 1,
      size: widget.particleSize + _random.nextDouble() * 2,
      color: widget.particleColor,
      opacity: 0.7 + _random.nextDouble() * 0.3,
      life: 60 + _random.nextDouble() * 120,
      maxLife: 60 + _random.nextDouble() * 120,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          children: [
            widget.child,
            if (widget.enabled)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: ParticlePainter(_particles),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Floating Elements Animation Widget
class FloatingElementsWidget extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final List<Color> colors;
  final int elementCount;

  const FloatingElementsWidget({
    super.key,
    required this.child,
    this.enabled = true,
    this.colors = const [Colors.blue, Colors.purple, Colors.pink],
    this.elementCount = 8,
  });

  @override
  State<FloatingElementsWidget> createState() => _FloatingElementsWidgetState();
}

class _FloatingElementsWidgetState extends State<FloatingElementsWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.elementCount,
      (index) => AnimationController(
        duration: Duration(
          milliseconds: 3000 + _random.nextInt(2000),
        ),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    if (widget.enabled) {
      for (var controller in _controllers) {
        controller.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Stack(
      children: [
        widget.child,
        IgnorePointer(
          child: Stack(
            children: List.generate(widget.elementCount, (index) {
              return AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  return Positioned(
                    left: _random.nextDouble() * 300,
                    top: 50 + _random.nextDouble() * 400,
                    child: Transform.translate(
                      offset: Offset(
                        sin(_animations[index].value * 2 * pi) * 20,
                        cos(_animations[index].value * 2 * pi) * 15,
                      ),
                      child: Opacity(
                        opacity: 0.1 + _animations[index].value * 0.3,
                        child: Container(
                          width: 20 + _random.nextDouble() * 30,
                          height: 20 + _random.nextDouble() * 30,
                          decoration: BoxDecoration(
                            color: widget.colors[index % widget.colors.length],
                            shape: _random.nextBool()
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                            borderRadius: _random.nextBool()
                                ? BorderRadius.circular(8)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}

// Morphing Background Widget
class MorphingBackgroundWidget extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration morphDuration;

  const MorphingBackgroundWidget({
    super.key,
    required this.child,
    required this.colors,
    this.morphDuration = const Duration(seconds: 8),
  });

  @override
  State<MorphingBackgroundWidget> createState() =>
      _MorphingBackgroundWidgetState();
}

class _MorphingBackgroundWidgetState extends State<MorphingBackgroundWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.morphDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                sin(_animation.value * 2 * pi) * 0.5,
                cos(_animation.value * 2 * pi) * 0.3,
              ),
              radius: 0.8 + _animation.value * 0.4,
              colors: [
                widget.colors[0].withOpacity(0.1),
                widget.colors[1].withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
