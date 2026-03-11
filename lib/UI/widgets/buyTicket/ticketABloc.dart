import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/enums/ticket_status.dart';

class TicketABloc extends StatelessWidget {
  final Ticket ticket;

  const TicketABloc({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isAvailable = ticket.status == TicketStatus.available;
    final isSelected = ticket.isSelected;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: 40,
        height: 30,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? validateBtnColor
                : isAvailable
                ? kPrimaryColor
                : greyBorderColor,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed: isAvailable
              ? () {
                  final provider = Provider.of<TicketProvider>(
                    context,
                    listen: false,
                  );
                  provider.toggleTicketSelection(ticket.id!);
                }
              : null,
          child: Text(
            ticket.id?.toString() ?? 'N/A',
            style: TextStyle(
              color: isSelected ? kSecondColor : kThirdColor,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
