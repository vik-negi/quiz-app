import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;
  final bool useSafeArea;

  const CustomScaffold({
    super.key,
    required this.body,
    this.floatingActionButton,
    this.useSafeArea = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: body,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: useSafeArea ? SafeArea(child: content) : content,
      floatingActionButton: floatingActionButton,
    );
  }
}
