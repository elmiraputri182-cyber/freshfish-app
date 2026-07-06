import 'package:flutter/material.dart';

class PremiumNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationDestination> destinations;

  const PremiumNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: 16,
        ),
        child: Material(
          elevation: 12,
          shadowColor: Colors.black12,
          borderRadius: BorderRadius.circular(30),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: NavigationBar(
              height: 72,
              elevation: 0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              selectedIndex: currentIndex,
              animationDuration: const Duration(
                milliseconds: 300,
              ),
              indicatorColor: const Color(0xffE3F2FD),
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              onDestinationSelected: onTap,
              destinations: destinations,
            ),
          ),
        ),
      ),
    );
  }
}