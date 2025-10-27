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
          color: card.isFlipped || card.isMatched
              ? Theme.of(context).cardColor
              : Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            card.isFlipped || card.isMatched ? card.title : '❓',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: card.isFlipped || card.isMatched
                  ? Theme.of(context).textTheme.bodyLarge?.color
                  : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
