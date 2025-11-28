import 'package:flutter/material.dart';

class FloatingActionButtonCustom extends StatelessWidget {
  final VoidCallback onAddClick;

  const FloatingActionButtonCustom({
    Key? key,
    required this.onAddClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.only(top: 10),
      child: FloatingActionButton(
        onPressed: onAddClick,
        elevation: 8,
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
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(249, 115, 22, 0.4),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.add, size: 32, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
