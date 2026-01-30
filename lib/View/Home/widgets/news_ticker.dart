import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import '../../../core/bloc/appBloc/appBloc.dart';
import '../../../core/bloc/appBloc/appState.dart';
import '../../../core/models/appModels/newsModel.dart';
import '../../../core/const/color_const.dart';

/// NewsTicker displays a scrolling ticker for news items
class NewsTicker extends StatefulWidget {
  const NewsTicker({super.key});

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        seconds: 18,
      ), // Reduced from 30 to 20 seconds for faster scrolling
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (previous, current) {
        // Rebuild when news changes
        if (previous is AppLoaded && current is AppLoaded) {
          return previous.news != current.news;
        }
        return true; // Always rebuild on state type change
      },
      builder: (context, state) {
        print('📰 [NEWS_TICKER] Building ticker widget');
        print('   - State type: ${state.runtimeType}');
        if (state is AppLoaded) {
          print('   - state.news: ${state.news}');
          if (state.news != null) {
            print('   - state.news.hasNews: ${state.news!.hasNews}');
            print('   - state.news.news.length: ${state.news!.news.length}');
            print(
              '   - state.news.news: ${state.news!.news.map((n) => n.title).toList()}',
            );
          }
        }

        if (state is AppLoaded &&
            state.news != null &&
            state.news!.hasNews &&
            state.news!.news.isNotEmpty) {
          print('📰 [NEWS_TICKER] ✅ Showing ticker');
          final scheme = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 10,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? scheme.primary.withOpacity(0.18)
                  : colorConst.primaryColor1.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: colorConst.primaryColor1.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: _buildTickerContent(context, state.news!.news),
          );
        }
        print('📰 [NEWS_TICKER] ❌ Hiding ticker (conditions not met)');
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTickerContent(BuildContext context, List<NewsItem> newsItems) {
    if (newsItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Combine all news items into a single scrolling text with icon
    final tickerText =
        '  ${newsItems.map((item) => '${item.title} • ${item.content}').join('  •  ')}';

    return SizedBox(
      height: 20,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _TickerPainter(
              text: tickerText,
              progress: _animation.value,
              color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.black87,
            ),
          );
        },
      ),
    );
  }
}

class _TickerPainter extends CustomPainter {
  final String text;
  final double progress;
  final Color color;

  _TickerPainter({required this.text, required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: color,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();

    final textWidth = textPainter.width;
    // Calculate offset so text starts from right side and scrolls to left
    // When progress = 0: offset = size.width (text starts off-screen right)
    // When progress = 1: offset = -textWidth (text fully disappears off-screen left)
    // Total distance = screen width + text width (so text fully exits before restarting)
    final totalDistance = size.width + textWidth;
    final offset = size.width - (progress * totalDistance);

    // Only draw the text once (no seamless loop)
    // This ensures the text fully disappears before restarting
    if (offset + textWidth >= 0 && offset <= size.width) {
      textPainter.paint(
        canvas,
        Offset(offset, (size.height - textPainter.height) / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_TickerPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.progress != progress;
  }
}
