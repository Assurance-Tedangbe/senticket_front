import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class CancelButtonWithBadge extends StatelessWidget {
  final VoidCallback onPressed;
  final bool hasTransferToCancel;

  const CancelButtonWithBadge({
    super.key,
    required this.onPressed,
    required this.hasTransferToCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          iconSize: 60,
          icon: const Icon(Icons.cancel, color: kPrimaryColor),
          tooltip: 'Annuler le dernier transfert',
          onPressed: onPressed,
        ),
        if (hasTransferToCancel)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: kSecondColor, width: 2),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: const Text(
                '1',
                style: TextStyle(
                  color: kSecondColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}