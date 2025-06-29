import 'package:flutter/material.dart';

class OverlayCard extends StatelessWidget {
  final Offset position;
  final VoidCallback onClose;
  final Widget child;

  const OverlayCard({
    super.key,
    required this.position,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onClose,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            left: position.dx,
            top: position.dy + 30,
            child: Material(
              color: Colors.transparent,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
