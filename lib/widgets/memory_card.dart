import 'package:flutter/material.dart';
import '../models/card_model.dart';

class MemoryCard extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;

  const MemoryCard({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: card.isFlipped || card.isMatched ? Colors.white : Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          card.isFlipped || card.isMatched ? card.title : '❓',
          style: TextStyle
