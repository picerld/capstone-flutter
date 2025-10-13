import 'package:flutter/material.dart';

class ShadcnBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ShadcnBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<ShadcnBottomNav> createState() => _ShadcnBottomNavState();
}

class _ShadcnBottomNavState extends State<ShadcnBottomNav> {
  int selected = 0;

  @override
  void initState() {
    super.initState();
    selected = widget.currentIndex;
  }

  @override
  void didUpdateWidget(ShadcnBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        selected = widget.currentIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(40),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0118), Color(0xFF1A0B2E), Color(0xFF0A0118)],
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.nightlight_outlined,
            activeIcon: Icons.nightlight,
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = selected == index;

    return GestureDetector(
      onTap: () {
        setState(() => selected = index);
        widget.onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.5),
          size: 26,
        ),
      ),
    );
  }
}
