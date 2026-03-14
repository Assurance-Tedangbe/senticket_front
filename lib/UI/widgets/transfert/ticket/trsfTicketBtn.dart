import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/provider/user_provider.dart';

class TransfertTicketBtn extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFormValid; // Nouveau paramètre

  const TransfertTicketBtn({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    required this.isFormValid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      width: 340,
      height: 95,
      child: ElevatedButton(
        onPressed: (isLoading || !isFormValid) ? null : onPressed,
        style: ElevatedButton.styleFrom(
        backgroundColor: _getButtonColor(),
        //isLoading ? greyBorderColor : kPrimaryColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(kSecondColor),
          ),
        )
            : const Text(
          'Transférer ticket(s)',
          style: TextStyle(
            color: kSecondColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
}
  Color _getButtonColor() {
    if (isLoading) {
      return greyBorderColor;
    }
    return isFormValid ? kPrimaryColor : greyBorderColor;
  }
}