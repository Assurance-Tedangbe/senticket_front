/* import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class SelectAllButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int selectedCount;
  final int totalCount;

  const SelectAllButton({
    super.key,
    required this.onPressed,
    required this.selectedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final isAllSelected = selectedCount == totalCount;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isAllSelected ? kPrimaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kPrimaryColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAllSelected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 16,
              color: isAllSelected ? Colors.white : kPrimaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              isAllSelected ? 'Tout désélectionner' : 'Tout sélectionner',
              style: TextStyle(
                fontSize: 12,
                color: isAllSelected ? Colors.white : kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
} */

import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class SelectAllButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int selectedCount;
  final int totalCount;
  final bool isForTicketsA;

  const SelectAllButton({
    super.key,
    required this.onPressed,
    required this.selectedCount,
    required this.totalCount,
    required this.isForTicketsA,
  });

  @override
  Widget build(BuildContext context) {
    final isAllSelected = totalCount > 0 && selectedCount == totalCount;
    final buttonText =
        isAllSelected ? 'Tout désélectionner' : 'Tout sélectionner';

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isAllSelected
              ? (isForTicketsA ? kPrimaryColor : Colors.cyan)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isForTicketsA ? kPrimaryColor : Colors.cyan,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAllSelected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 16,
              color: isAllSelected
                  ? Colors.white
                  : (isForTicketsA ? kPrimaryColor : Colors.cyan),
            ),
            const SizedBox(width: 4),
            Text(
              buttonText,
              style: TextStyle(
                fontSize: 12,
                color: isAllSelected
                    ? Colors.white
                    : (isForTicketsA ? kPrimaryColor : Colors.cyan),
              ),
            ),
            if (selectedCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isForTicketsA ? kPrimaryColor : Colors.cyan,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$selectedCount/$totalCount',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
