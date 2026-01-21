import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/buyTicket/buyTicketBtn.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/ticket_provider.dart';

class RequestSection extends StatefulWidget {
  const RequestSection({super.key});

  @override
  State<RequestSection> createState() => _RequestSectionState();
}

class _RequestSectionState extends State<RequestSection> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
    });

    // Désélectionner tous les tickets
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    ticketProvider.clearAllSelections();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        final selectedCount = ticketProvider.selectedTickets.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                // border: Border.all(color: kPrimaryColor, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: /* Column(
                //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [ */
                    /* Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /*  ClientNameSection(
                          onChanged: (value) {
                            setState(() {
                              buyerName = value;
                            });
                          },
                        ), */
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Tickets sélectionnés',
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              selectedCount.toString(),
                              style: const TextStyle(
                                color: kPrimaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ), */
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /* ElevatedButton.icon(
                          onPressed: buyerName.isNotEmpty || selectedCount > 0
                              ? _clearForm
                              : null,
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Effacer tout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            minimumSize: Size(size.width * 0.25, 40),
                          ),
                        ), */
                        BuyTicketBtn(
                          onSuccess: () {
                            _clearForm();
                          },
                        ),
                      ],
                    ),
                //  ],
                //  ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/* Impl. sans dynamisation
class RequestSection extends StatelessWidget {
  const RequestSection({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        height: size.height / 5.0,
        decoration: BoxDecoration(
            color: ticketSectionColor,
            borderRadius: const BorderRadius.all(Radius.circular(17.0)),
            boxShadow: const [
              BoxShadow(
                  color: boxshadowColor, blurRadius: 6, offset: Offset(0, 2))
            ],
            border: Border.all(color: kPrimaryColor, width: 1)),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClientNameSection(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BuyTicketBtn(),
                ],
              ),
            ],
          ),
        ),
      ),
    ]);
  }
} */
