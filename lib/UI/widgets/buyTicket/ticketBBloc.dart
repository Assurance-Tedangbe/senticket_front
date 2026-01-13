/* import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class TicketBBloc extends StatefulWidget {
  final String ticketBLibelle;
  const TicketBBloc({super.key, required this.ticketBLibelle});

  @override
  State<TicketBBloc> createState() => _TicketBBlocState();
}

class _TicketBBlocState extends State<TicketBBloc> {
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
              backgroundColor: Colors.cyan,
            ),
            onPressed: () => print('book ticket'),
            child: Text(
              // "${ticket['place']['numero']}"
              widget.ticketBLibelle,
              style: const TextStyle(color: kThirdColor, fontSize: 12),
            )),
      ),
    );
  }
} */

//Présentation d'un ticket de type B avec gestion de la sélection
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/enums/ticket_status.dart';

class TicketBBloc extends StatelessWidget {
  final Ticket ticket;

  const TicketBBloc({super.key, required this.ticket});

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
                ? Colors.green
                : isAvailable
                    ? Colors.cyan
                    : Colors.grey,
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
              color: isSelected ? Colors.white : kThirdColor,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/* 
// 1ere proposition avec dynamisation
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/constants.dart';

class TicketBBloc extends StatelessWidget {
  final Ticket ticket;

  const TicketBBloc({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isAvailable = ticket.ticketStatus == TicketStatus.AVAILABLE;
    final isSelected = ticket.isSelected ?? false;
    
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Colors.green // Couleur quand sélectionné
              : isAvailable
                  ? kPrimaryColor // Disponible
                  : Colors.grey, // Non disponible
          minimumSize: Size(40, 30),
          padding: EdgeInsets.zero,
        ),
        onPressed: isAvailable
            ? () {
                final provider = Provider.of<TicketProvider>(
                  context,
                  listen: false,
                );
                provider.toggleTicketSelection(ticket.ticketId!);
              }
            : null, // Désactivé si non disponible
        child: Text(
          ticket.ticketId?.toString() ?? 'N/A',
          style: TextStyle(
            color: isSelected ? Colors.white : kThirdColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
} */