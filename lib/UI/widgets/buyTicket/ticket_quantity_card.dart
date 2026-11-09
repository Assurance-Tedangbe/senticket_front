import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class TicketQuantityCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final double unitPrice;
  final Color color;
  final int count;
  final bool canIncrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const TicketQuantityCard({
    super.key,
    required this.label,
    required this.subtitle,
    required this.unitPrice,
    required this.color,
    required this.count,
    required this.canIncrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final active = count > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ticketSectionColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color, width: active ? 2 : 1),
        boxShadow: const [
          BoxShadow(color: boxshadowColor, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kThirdColor)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: kThirdColor.withValues(alpha: 0.6))),
                const SizedBox(height: 2),
                Text('${unitPrice.toInt()} FCFA / ticket',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: color)),
              ],
            ),
          ),
          IconButton(
            onPressed: active ? onDecrement : null,
            icon: Icon(Icons.remove_circle_outline,
                size: 30, color: active ? color : greyBorderColor),
            tooltip: 'Retirer un ticket',
          ),
          SizedBox(
            width: 30,
            child: Text('$count',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: active ? color : kThirdColor)),
          ),
          IconButton(
            onPressed: canIncrement ? onIncrement : null,
            icon: Icon(Icons.add_circle_outline,
                size: 30, color: canIncrement ? color : greyBorderColor),
            tooltip: 'Ajouter un ticket',
          ),
        ],
      ),
    );
  }
}