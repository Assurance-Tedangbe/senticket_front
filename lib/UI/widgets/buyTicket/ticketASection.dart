import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/buyTicket/selectAllButton.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticketABloc.dart';
import 'package:senticket_front/UI/widgets/home/bloctitle.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/ticket_provider.dart';

class TicketASection extends StatefulWidget {
  const TicketASection({super.key});

  @override
  State<TicketASection> createState() => _TicketASectionState();
}

class _TicketASectionState extends State<TicketASection> {
  @override
  void initState() {
    super.initState();
    // Charger les tickets au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ticketProvider = Provider.of<TicketProvider>(
        context,
        listen: false,
      );
      ticketProvider.loadAllTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        final ticketsA = ticketProvider.ticketsA;
        final selectedCount = ticketsA.where((t) => t.isSelected).length;
        final totalCount = ticketsA.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BlocTitle(text: "Tickets A(petit-déj.)"),
                if (ticketsA.isNotEmpty)
                  SelectAllButton(
                    onPressed: () => ticketProvider.selectAllTicketsA(),
                    selectedCount: selectedCount,
                    totalCount: totalCount,
                    isForTicketsA: true,
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
                  ),
                ],
                border: Border.all(color: kPrimaryColor, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ticketProvider.isLoading && ticketsA.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: kPrimaryColor),
                      )
                    : ticketsA.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.confirmation_number,
                              size: 40,
                              color: greyBorderColor,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Aucun ticket A disponible',
                              style: TextStyle(
                                color: greyBorderColor,
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
                          children: ticketsA
                              .map((ticket) => TicketABloc(ticket: ticket))
                              .toList(),
                        ),
                      ),
              ),
            ),
            if (ticketsA.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$selectedCount sur $totalCount sélectionné(s)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: kThirdColor,
                        fontWeight: FontWeight.bold,
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

/*Ancienne version sans dynamisation

class TicketASection extends StatefulWidget {
  const TicketASection({super.key});

  @override
  State<TicketASection> createState() => _TicketASectionState();
}

class _TicketASectionState extends State<TicketASection> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [BlocTitle(text: "Tickets A")],
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
              padding: const EdgeInsets.all(2.0),
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
            TicketABloc(ticketLibelle: "1"),
            TicketABloc(ticketLibelle: "2"),
            // })
          ]),
        ),
      ),
    ]);
  }
} */