//Présentation d'un ticket de type B avec gestion de la sélection
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
    final isAvailable = ticket.ticketStatus == TicketStatus.available;
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
                  provider.toggleTicketSelection(ticket.ticketId!);
                }
              : null,
          child: Text(
            ticket.ticketId?.toString() ?? 'N/A',
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

/* import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class TicketABloc extends StatefulWidget {
  final String ticketLibelle;
  const TicketABloc({super.key, required this.ticketLibelle});

  @override
  State<TicketABloc> createState() => _TicketABlocState();
}

class _TicketABlocState extends State<TicketABloc> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: size.width * 0.12,
        height: size.height * 0.03,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
            ),
            onPressed: () => print('book ticket'),
            child: Text(
              // "${ticket['place']['numero']}"
              widget.ticketLibelle,
              style: const TextStyle(color: kThirdColor, fontSize: 12),
            )),
      ),
    );
  }
} */
