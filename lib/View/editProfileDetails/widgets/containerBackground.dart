import 'package:flutter/material.dart';

/// Constructor for the background container.
class backgroundContainer extends StatefulWidget {
  final List<Widget>Widgets;
  const backgroundContainer({super.key,required this.Widgets});

  @override
  State<backgroundContainer> createState() => _backgroundContainerState();
}

class _backgroundContainerState extends State<backgroundContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width*0.93,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.05),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          children: [
            ...widget.Widgets,
          ],
        ),
      ),
    );
  }
}
