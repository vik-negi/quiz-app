import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../widgets/custom_scaffold.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_logo.dart';
import 'quiz_screen.dart';
import '../../../history/presentation/screens/history_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScaffold(
      body: _WelcomeContent(),
    );
  }
}

class _WelcomeContent extends StatefulWidget {
  const _WelcomeContent();

  @override
  State<_WelcomeContent> createState() => _WelcomeContentState();
}

class _WelcomeContentState extends State<_WelcomeContent>
    with TickerProviderStateMixin {
  String _selectedDifficulty = 'easy';
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late AnimationController _textController;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(_createRoute(page));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          CustomLogo(animation: _logoScaleAnimation),
          const SizedBox(height: 40),
          _WelcomeText(animation: _textFadeAnimation),
          const SizedBox(height: 32),
          _DifficultyDropdown(
            selectedDifficulty: _selectedDifficulty,
            onChanged: (value) => setState(() => _selectedDifficulty = value),
          ),
          const Spacer(),
          CustomButton(
            label: 'Start Quiz',
            onPressed: () {
              context
                  .read<QuizBloc>()
                  .add(FetchQuizQuestions(_selectedDifficulty));
              _navigateTo(context, const QuizScreen());
            },
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: 'View History',
            onPressed: () => _navigateTo(context, const HistoryScreen()),
            isElevated: false,
          ),
        ],
      ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  final Animation<double> animation;

  const _WelcomeText({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: animation,
          child: Text(
            'Ready to test\nyour knowledge?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
          ),
        ),
        const SizedBox(height: 16),
        FadeTransition(
          opacity: animation,
          child: Text(
            'Challenge yourself with our curated quizzes and see how you stack up!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.7),
                ),
          ),
        ),
      ],
    );
  }
}

class _DifficultyDropdown extends StatelessWidget {
  final String selectedDifficulty;
  final ValueChanged<String> onChanged;

  const _DifficultyDropdown({
    required this.selectedDifficulty,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: DropdownButton<String>(
        value: selectedDifficulty,
        items: ['easy', 'medium', 'hard']
            .map((difficulty) => DropdownMenuItem<String>(
                  value: difficulty,
                  child: Text(difficulty.capitalize()),
                ))
            .toList(),
        onChanged: (value) => onChanged(value!),
        underline: Container(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutCubic;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
