/* import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticketBBloc.dart';
import 'package:senticket_front/UI/widgets/home/bloctitle.dart';
import 'package:senticket_front/constants.dart';

class TicketBSection extends StatefulWidget {
  const TicketBSection({super.key});

  @override
  State<TicketBSection> createState() => _TicketBSectionState();
}

class _TicketBSectionState extends State<TicketBSection> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [BlocTitle(text: "Tickets B")],
      ),
      Container(
        width: double.infinity,
        height: size.height / 6.0,
        decoration: BoxDecoration(
            color: ticketSectionColor,
            borderRadius: const BorderRadius.all(Radius.circular(17.0)),
            boxShadow: const [
              BoxShadow(
                  color: boxshadowColor, blurRadius: 6, offset: Offset(0, 2))
            ],
            border: Border.all(color: kPrimaryColor, width: 1)),
        child: const Padding(
          padding: EdgeInsets.all(2.0),
          child: Wrap(children: [
            //   ...this.listSallles[index]['currentProjection']['listTickets'].map((ticket){
            //    return
            /*  Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                 width: size.width * 0.12,
                 height: size.height * 0.03,
                //  width: 40,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                    ),
                    onPressed: () => print('book ticket'),
                    child: const Text(
                      // "${ticket['place']['numero']}"
                      "1",
                      style: TextStyle(color: kThirdColor, fontSize: 12),
                    )),
              ),
            ), */
            TicketBBloc(ticketBLibelle: "1"),
            TicketBBloc(ticketBLibelle: "2"),
            TicketBBloc(ticketBLibelle: "3"),
            TicketBBloc(ticketBLibelle: "4"),
            TicketBBloc(ticketBLibelle: "5"),
            TicketBBloc(ticketBLibelle: "6"),
            TicketBBloc(ticketBLibelle: "7"),
            TicketBBloc(ticketBLibelle: "8"),
            TicketBBloc(ticketBLibelle: "9"),
            TicketBBloc(ticketBLibelle: "10"),
            TicketBBloc(ticketBLibelle: "11"),
            TicketBBloc(ticketBLibelle: "12"),
            TicketBBloc(ticketBLibelle: "13"),
            TicketBBloc(ticketBLibelle: "14"),
            TicketBBloc(ticketBLibelle: "15"),
            TicketBBloc(ticketBLibelle: "16"),
            TicketBBloc(ticketBLibelle: "17"),
            TicketBBloc(ticketBLibelle: "18"),
            TicketBBloc(ticketBLibelle: "19"),
            TicketBBloc(ticketBLibelle: "20"),
            TicketBBloc(ticketBLibelle: "21"),
            TicketBBloc(ticketBLibelle: "22"),
            TicketBBloc(ticketBLibelle: "23"),
            TicketBBloc(ticketBLibelle: "24"),
            // })
          ]),
        ),
      ),
    ]);
  }
} */

import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/buyTicket/selectAllButton.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticketBBloc.dart';
import 'package:senticket_front/UI/widgets/home/bloctitle.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/ticket_provider.dart';

class TicketBSection extends StatefulWidget {
  const TicketBSection({super.key});

  @override
  State<TicketBSection> createState() => _TicketBSectionState();
}

class _TicketBSectionState extends State<TicketBSection> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        final ticketsB = ticketProvider.ticketsB;
        final selectedCount = ticketsB.where((t) => t.isSelected).length;
        final totalCount = ticketsB.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BlocTitle(text: "Tickets B"),
                if (ticketsB.isNotEmpty)
                  SelectAllButton(
                    onPressed: () => ticketProvider.selectAllTicketsB(),
                    selectedCount: selectedCount,
                    totalCount: totalCount,
                    isForTicketsA: false,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: size.height / 6.0,
              decoration: BoxDecoration(
                color: ticketSectionColor,
                borderRadius: const BorderRadius.all(Radius.circular(17.0)),
                boxShadow: const [
                  BoxShadow(
                    color: boxshadowColor,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
                border: Border.all(color: Colors.cyan, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ticketProvider.isLoading && ticketsB.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.cyan),
                      )
                    : ticketsB.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.confirmation_number,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Aucun ticket B disponible',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: ticketsB
                                  .map((ticket) => TicketBBloc(ticket: ticket))
                                  .toList(),
                            ),
                          ),
              ),
            ),
            if (ticketsB.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$selectedCount sur $totalCount sélectionné(s)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.cyan,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/* 
// 1ere proposition sans dynamisation
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticketBBloc.dart';
import 'package:senticket_front/UI/widgets/home/bloctitle.dart';
import 'package:senticket_front/UI/widgets/buyTicket/select_all_button.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/ticket_provider.dart';

class TicketBSection extends StatefulWidget {
  const TicketBSection({super.key});

  @override
  State<TicketBSection> createState() => _TicketBSectionState();
}

class _TicketBSectionState extends State<TicketBSection> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        final ticketsB = ticketProvider.ticketsB;
        final selectedCount = ticketsB.where((t) => t.isSelected == true).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BlocTitle(text: "Tickets B"),
                if (ticketsB.isNotEmpty)
                  SelectAllButton(
                    onPressed: () => ticketProvider.selectAllTicketsB(),
                    selectedCount: selectedCount,
                    totalCount: ticketsB.length,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: size.height / 6.0,
              decoration: BoxDecoration(
                color: ticketSectionColor,
                borderRadius: const BorderRadius.all(Radius.circular(17.0)),
                boxShadow: const [
                  BoxShadow(
                    color: boxshadowColor,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
                border: Border.all(color: kPrimaryColor, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ticketProvider.isLoading && ticketsB.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: kPrimaryColor),
                      )
                    : ticketsB.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun ticket B disponible',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: ticketsB
                                  .map((ticket) => TicketBBloc(ticket: ticket))
                                  .toList(),
                            ),
                          ),
              ),
            ),
          ],
        );
      },
    );
  }
} */