import 'package:flutter/material.dart';

class CustomLogo extends StatelessWidget {
  final Animation<double>? animation;
  final double size;
  final double padding;
  final bool useShadow;

  const CustomLogo({
    super.key,
    this.animation,
    this.size = 60,
    this.padding = 16,
    this.useShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: useShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.quiz_rounded,
        size: size,
        color: Theme.of(context).colorScheme.primary,
      ),
    );

    return Hero(
      tag: 'quiz-logo',
      child: animation != null
          ? ScaleTransition(scale: animation!, child: logo)
          : logo,
    );
  }
}
