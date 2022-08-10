import 'package:flutter/material.dart';

class AnimatedRailWidget extends StatelessWidget {
  final Widget child;
  const AnimatedRailWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animation = NavigationRail.extendedAnimation(context);
    return AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) => SizedBox(
              height: 56,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: FloatingActionButton.extended(
                    onPressed: () {},
                    backgroundColor: Colors.red,
                    label: child!,
                    isExtended: animation.status != AnimationStatus.dismissed),
              ),
            ));
  }
}
