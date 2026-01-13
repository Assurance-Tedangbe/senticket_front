/* import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class BuyTicketBtn extends StatefulWidget {
  const BuyTicketBtn({super.key});

  @override
  State<BuyTicketBtn> createState() => _BuyTicketBtnState();
}

class _BuyTicketBtnState extends State<BuyTicketBtn> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.3,
      height: size.height / 14.0,
      child: ElevatedButton(
        onPressed: () => print('buy pressed'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          textStyle: const TextStyle(
              color: kSecondColor, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        child: const Text('Acheter'),
      ),
    );
  }
} */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/ticket_provider.dart';

class BuyTicketBtn extends StatelessWidget {
  final String buyerName;
  final VoidCallback onSuccess;

  const BuyTicketBtn({
    super.key,
    required this.buyerName,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        final selectedTickets = ticketProvider.selectedTickets;
        final selectedCount = selectedTickets.length;
        final isProcessing = ticketProvider.isPurchasingTickets;

        double totalPrice = 0;
        for (var ticket in selectedTickets) {
          totalPrice += ticket.ticketPrice;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (selectedCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kPrimaryColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$selectedCount ticket(s) sélectionné(s)',
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Total: ${totalPrice.toStringAsFixed(2)} FCFA',
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(
              width: size.width * 0.3,
              height: size.height / 14.0,
              child: ElevatedButton(
                onPressed:
                    isProcessing || selectedCount == 0 || buyerName.isEmpty
                        ? null
                        : () async {
                            final success = await ticketProvider
                                .purchaseSelectedTickets(buyerName);

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$selectedCount ticket(s) acheté(s) avec succès pour $buyerName',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                              onSuccess();
                            } else if (ticketProvider.error.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ticketProvider.error),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isProcessing
                      ? Colors.grey
                      : (selectedCount == 0 || buyerName.isEmpty)
                          ? Colors.grey
                          : kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Acheter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
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
import 'package:provider/provider.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/ticket_provider.dart';

class BuyTicketBtn extends StatefulWidget {
  final String buyerName;
  final VoidCallback onSuccess;

  const BuyTicketBtn({
    super.key,
    required this.buyerName,
    required this.onSuccess,
  });

  @override
  State<BuyTicketBtn> createState() => _BuyTicketBtnState();
}

class _BuyTicketBtnState extends State<BuyTicketBtn> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        final selectedCount = ticketProvider.selectedTickets.length;
        final isProcessing = ticketProvider.isPurchasingTickets;
        final totalPrice = ticketProvider.selectedTickets.fold(
          0.0,
          (sum, ticket) => sum + ticket.ticketPrice,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (selectedCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '$selectedCount ticket(s) sélectionné(s) - ${totalPrice.toStringAsFixed(2)} FCFA',
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            SizedBox(
              width: size.width * 0.3,
              height: size.height / 14.0,
              child: ElevatedButton(
                onPressed: isProcessing || selectedCount == 0 || widget.buyerName.isEmpty
                    ? null
                    : () async {
                        final success = await ticketProvider.purchaseSelectedTickets(
                          widget.buyerName,
                        );
                        
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$selectedCount ticket(s) acheté(s) avec succès pour ${widget.buyerName}',
                              ),
                              backgroundColor: validateBtnColor,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          widget.onSuccess();
                        } else if (ticketProvider.error.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ticketProvider.error),
                              backgroundColor: errorColor,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isProcessing 
                    ? Colors.grey 
                    : (selectedCount == 0 || widget.buyerName.isEmpty)
                      ? Colors.grey
                      : kPrimaryColor,
                  shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  textStyle: const TextStyle(
                    color: kSecondColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Acheter'),
              ),
            ),
          ],
        );
      },
    );
  }
} */
