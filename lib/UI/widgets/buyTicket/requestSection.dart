/* import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/buyTicket/buyTicketBtn.dart';
import 'package:senticket_front/UI/widgets/buyTicket/clientNameSection.dart';
import 'package:senticket_front/constants.dart';

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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/buyTicket/buyTicketBtn.dart';
import 'package:senticket_front/UI/widgets/buyTicket/clientNameSection.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/ticket_provider.dart';

class RequestSection extends StatefulWidget {
  const RequestSection({super.key});

  @override
  State<RequestSection> createState() => _RequestSectionState();
}

class _RequestSectionState extends State<RequestSection> {
  String buyerName = '';
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      buyerName = '';
      _nameController.clear();
    });

    // Désélectionner tous les tickets
    final ticketProvider = Provider.of<TicketProvider>(
      context,
      listen: false,
    );
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
                  )
                ],
                border: Border.all(color: kPrimaryColor, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClientNameSection(
                          onChanged: (value) {
                            setState(() {
                              buyerName = value;
                            });
                          },
                        ),
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
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
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
                        ),
                        BuyTicketBtn(
                          buyerName: buyerName,
                          onSuccess: () {
                            _clearForm();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/* 
1ere proposition avec dynamisation
import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/buyTicket/buyTicketBtn.dart';
import 'package:senticket_front/UI/widgets/buyTicket/clientNameSection.dart';
import 'package:senticket_front/constants.dart';

class RequestSection extends StatefulWidget {
  const RequestSection({super.key});

  @override
  State<RequestSection> createState() => _RequestSectionState();
}

class _RequestSectionState extends State<RequestSection> {
  String buyerName = '';

  void _clearSelection() {
    // Cette méthode sera implémentée dans BuyTicketBody
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
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
              )
            ],
            border: Border.all(color: kPrimaryColor, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClientNameSection(
                      initialValue: buyerName,
                      onChanged: (value) {
                        setState(() {
                          buyerName = value;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: buyerName.isNotEmpty
                          ? () {
                              setState(() {
                                buyerName = '';
                              });
                            }
                          : null,
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Effacer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        minimumSize: Size(size.width * 0.2, 40),
                      ),
                    ),
                    BuyTicketBtn(
                      buyerName: buyerName,
                      onSuccess: () {
                        setState(() {
                          buyerName = '';
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} */