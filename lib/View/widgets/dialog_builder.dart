import 'package:flutter/material.dart';

/// A widget that builds a dialog with customizable width factors based on different screen sizes.
class DialogBuilder extends StatelessWidget {
  /// Creates a [DialogBuilder] widget.
  ///
  /// The [child] parameter must not be null.
  const DialogBuilder({
    super.key,
    required this.child,
    this.desktopFactor,
    this.tabletFactor,
    this.mobileFactor,
  });

  /// The widget to display within the dialog.
  final Widget child;

  /// The width factor to use for desktop screens.
  /// Defaults to 0.5 if not provided.
  final double? desktopFactor;

  /// The width factor to use for tablet screens.
  /// Defaults to 0.80 if not provided.
  final double? tabletFactor;

  /// The width factor to use for mobile screens.
  /// Defaults to 1.0 if not provided.
  final double? mobileFactor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double widthFactor;

          if (constraints.maxWidth >= 1200) {
            // Desktop screen
            widthFactor = desktopFactor ?? 0.5;
          } else if (constraints.maxWidth >= 600) {
            // Tablet screen
            widthFactor = tabletFactor ?? 0.80;
          } else {
            // Mobile screen
            widthFactor = mobileFactor ?? 1.0;
          }

          return FractionallySizedBox(
            widthFactor: widthFactor,
            child: Dialog(
              insetPadding: const EdgeInsets.all(8),
              // backgroundColor: Theme.of(context).cardTheme.color,
              clipBehavior: Clip.hardEdge,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
