import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

/// Widget affiché quand une page ne peut pas charger ses données.
/// Affiche un message clair + bouton de retry.
class NetworkErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const NetworkErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: greyBorderColor),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: kThirdColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: kPrimaryColor),
              label: const Text(
                'Réessayer',
                style: TextStyle(color: kPrimaryColor),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kPrimaryColor),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}