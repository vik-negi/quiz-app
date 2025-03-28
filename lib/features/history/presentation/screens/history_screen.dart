import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:quiz_app/features/quiz/presentation/widgets/custom_logo.dart';
import 'package:quiz_app/features/quiz/presentation/widgets/custom_scaffold.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryBloc()..add(FetchHistory()),
      child: CustomScaffold(
        body: const _HistoryContent(),
        floatingActionButton: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoaded && state.history.isNotEmpty) {
              return FloatingActionButton(
                onPressed: () {
                  context.read<HistoryBloc>().add(ClearHistory());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quiz history cleared!')),
                  );
                },
                child: const Icon(Icons.delete),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoaded) {
          final history = state.history;
          return Column(
            children: [
              _Header(onClose: () => Navigator.of(context).pop()),
              Expanded(
                child: history.isEmpty
                    ? const _EmptyHistory()
                    : _HistoryList(history: history),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;

  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 32, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomLogo(size: 24, padding: 8, useShadow: false),
          Text(
            'Quiz History',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No history yet.',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const _HistoryList({required this.history});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24.0, 12, 24, 24),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        return _HistoryItem(entry: entry, index: index);
      },
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final Map<String, dynamic> entry;
  final int index;

  const _HistoryItem({required this.entry, required this.index});

  String _formatTimestamp(dynamic timestamp) {
    final dateTime = DateTime.parse(timestamp.toString());
    return DateFormat('MM/dd/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 100 + (index * 100)),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry['question'],
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your Answer: ${entry['userAnswer'] ?? 'Skipped'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Correct Answer: ${entry['correctAnswer']}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: entry['userAnswer'] == entry['correctAnswer']
                                ? Colors.green
                                : Colors.red,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      DateFormat('d MMMM yy, ha').format(
                          DateTime.parse(entry['timestamp'].toString())),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
