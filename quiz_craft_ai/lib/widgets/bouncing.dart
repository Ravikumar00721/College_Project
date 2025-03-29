import 'package:flutter/material.dart';

class BouncingDotsLoader extends StatefulWidget {
  final Color color;
  final double dotSize;
  final Duration duration;

  const BouncingDotsLoader({
    this.color = Colors.blue,
    this.dotSize = 20.0,
    this.duration = const Duration(milliseconds: 800),
    Key? key,
  }) : super(key: key);

  @override
  _BouncingDotsLoaderState createState() => _BouncingDotsLoaderState();
}

class _BouncingDotsLoaderState extends State<BouncingDotsLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: widget.duration,
      )..repeat(reverse: true);
    });

    _animations = _controllers.map((controller) {
      return Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    // Stagger the animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _controllers[1].forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _controllers[2].forward();
    });
    _controllers[0].forward();
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0.0, -_animations[index].value * 15),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: widget.dotSize,
                height: widget.dotSize,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
