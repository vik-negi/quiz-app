import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';
import '../widgets/custom_scaffold.dart';
import '../widgets/custom_logo.dart';
import '../../../result/presentation/screens/result_screen.dart';
import '../../domain/entities/quiz_question.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _QuizContent(),
      ),
    );
  }
}

class _QuizContent extends StatefulWidget {
  const _QuizContent();

  @override
  State<_QuizContent> createState() => _QuizContentState();
}

class _QuizContentState extends State<_QuizContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  int _lastQuestionIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateProgressAnimation(int currentIndex, int totalQuestions) {
    if (_lastQuestionIndex != currentIndex) {
      _progressAnimation = Tween<double>(
        begin:
            _lastQuestionIndex < 0 ? 0.0 : _lastQuestionIndex / totalQuestions,
        end: (currentIndex + 1) / totalQuestions,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.forward(from: 0);
      _lastQuestionIndex = currentIndex;
    }
  }

  void _navigateToResult(BuildContext context, int score, int totalQuestions) {
    Navigator.of(context).pushReplacement(_createRoute(ResultScreen(
      score: score,
      totalQuestions: totalQuestions,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is QuizLoaded &&
            state.currentIndex >= state.questions.length) {
          _navigateToResult(context, state.score, state.questions.length);
        }
      },
      builder: (context, state) {
        if (state is QuizLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is QuizLoaded) {
          if (state.questions.isEmpty ||
              state.currentIndex >= state.questions.length)
            return const SizedBox();
          final currentQuestion = state.questions[state.currentIndex];
          _updateProgressAnimation(state.currentIndex, state.questions.length);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _Header(
                currentIndex: state.currentIndex,
                totalQuestions: state.questions.length,
                timerSeconds: state.timerSeconds,
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 24),
              _ProgressBar(animation: _progressAnimation),
              const SizedBox(height: 32),
              _QuestionText(
                question: currentQuestion.question,
                index: state.currentIndex,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: _OptionsList(
                  question: currentQuestion,
                  questionIndex: state.currentIndex,
                  onAnswerSelected: (answer) {
                    context
                        .read<QuizBloc>()
                        .add(AnswerQuestion(state.currentIndex, answer));
                  },
                ),
              ),
            ],
          );
        } else if (state is QuizError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }
}

class _Header extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final int timerSeconds;
  final VoidCallback onClose;

  const _Header({
    required this.currentIndex,
    required this.totalQuestions,
    required this.timerSeconds,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CustomLogo(size: 24, padding: 8, useShadow: false),
        Text(
          'Question ${currentIndex + 1}/$totalQuestions',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                'Time: ${timerSeconds}s',
                key: ValueKey(timerSeconds),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
          ],
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final Animation<double> animation;

  const _ProgressBar({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: animation.value,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary),
            minHeight: 8,
          ),
        );
      },
    );
  }
}

class _QuestionText extends StatelessWidget {
  final String question;
  final int index;

  const _QuestionText({required this.question, required this.index});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(0.1, 0.0), end: Offset.zero)
                    .animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        question,
        key: ValueKey<int>(index),
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _OptionsList extends StatefulWidget {
  final QuizQuestion question;
  final int questionIndex;
  final Function(String) onAnswerSelected;

  const _OptionsList({
    required this.question,
    required this.questionIndex,
    required this.onAnswerSelected,
  });

  @override
  State<_OptionsList> createState() => _OptionsListState();
}

class _OptionsListState extends State<_OptionsList> {
  int _selectedOptionIndex = -1;
  bool _hasAnswered = false;

  void _checkAnswer(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedOptionIndex = index;
      _hasAnswered = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _selectedOptionIndex = -1;
          _hasAnswered = false;
        });
        widget.onAnswerSelected(widget.question.options[index]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.question.options.length,
      itemBuilder: (context, index) {
        final option = widget.question.options[index];
        final isCorrect = option == widget.question.correctAnswer;
        final isSelected = index == _selectedOptionIndex;

        Color getBackgroundColor() {
          if (!_hasAnswered) return Theme.of(context).colorScheme.surface;
          if (isSelected)
            return isCorrect ? Colors.green.shade100 : Colors.red.shade100;
          if (isCorrect) return Colors.green.shade100;
          return Theme.of(context).colorScheme.surface;
        }

        Color getBorderColor() {
          if (!_hasAnswered) {
            return isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3);
          }
          if (isSelected) return isCorrect ? Colors.green : Colors.red;
          if (isCorrect) return Colors.green;
          return Theme.of(context).colorScheme.outline;
        }

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (index * 100)),
          curve: Curves.easeOutQuad,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: GestureDetector(
            onTap: () => _checkAnswer(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getBackgroundColor(),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: getBorderColor(), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                        : Center(
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (_hasAnswered)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: 1.0,
                      child: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
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
