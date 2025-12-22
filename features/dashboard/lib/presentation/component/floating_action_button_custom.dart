import 'package:flutter/material.dart';

class FloatingActionButtonCustom extends StatelessWidget {
  final VoidCallback onAddClick;

  const FloatingActionButtonCustom({super.key, required this.onAddClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.only(top: 10),
      child: FloatingActionButton(
        heroTag: 'dashboardFab',
        onPressed: onAddClick,
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: const CircleBorder(),
        child: Ink(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color(0xFFF97316),
                Color(0xFFFB923C),
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.add,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
