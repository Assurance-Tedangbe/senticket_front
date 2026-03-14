import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/provider/user_provider.dart';

class TransfertTicketBtn extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const TransfertTicketBtn({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
        builder: (context, userProvider, _) {
      return Consumer<TicketProvider>(
          builder: (context, ticketProvider, child) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      width: 340,
      height: 95,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
        backgroundColor: isLoading ? greyBorderColor : kPrimaryColor,
          /* isLoading &&
              !userProvider.isTransferUserFormValid && ticketProvider.isTransferringTickets
              ? kPrimaryColor
              : greyBorderColor,*/
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        child: isLoading && ticketProvider.isTransferringTickets
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
  });
  });
}
}