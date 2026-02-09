import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/buyTicket/selectAllButton.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticketBBloc.dart';
import 'package:senticket_front/UI/widgets/customWidgets/customCircularProgressIndicator.dart';
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
                const BlocTitle(text: "Tickets B(déj./dîner)"),
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
              height: size.height / 5.0,
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
                border: Border.all(color: cyanColor, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ticketProvider.isLoading && ticketsB.isEmpty
                    ? const Center(child: CustomCircularProgressIndicator())
                    : ticketsB.isEmpty
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
                              'Aucun ticket B disponible',
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
