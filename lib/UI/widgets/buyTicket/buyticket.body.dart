/* import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/buyTicket/requestSection.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticketASection.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticketBSection.dart';
import 'package:senticket_front/UI/widgets/home/sizebox.height.dart';
import 'package:senticket_front/UI/widgets/home/sizebox.template.dart';

class BuyTicketBody extends StatelessWidget {
  const BuyTicketBody({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 0),
          child: SizedBox(
            height: size.height,
            width: size.width,
            child: const Column(children: [
              TicketASection(),
              SizeboxTemplate(),
              TicketBSection(),
              SizeboxHeight(),
              RequestSection()
            ]),
          ),
        ),
      ),
    );
  }
} */

import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/services/ticket_service.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/buyTicket/requestSection.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticketASection.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticketBSection.dart';
import 'package:senticket_front/UI/widgets/home/sizebox.height.dart';
import 'package:senticket_front/UI/widgets/home/sizebox.template.dart';
import 'package:senticket_front/provider/ticket_provider.dart';

class BuyTicketBody extends StatefulWidget {
  const BuyTicketBody({super.key});

  @override
  State<BuyTicketBody> createState() => _BuyTicketBodyState();
}

class _BuyTicketBodyState extends State<BuyTicketBody> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ChangeNotifierProvider(
      create: (context) => TicketProvider(TicketApiService()),
      child: Background(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 0),
            child: SizedBox(
              width: size.width,
              child: Column(
                children: [
                  Consumer<TicketProvider>(
                    builder: (context, ticketProvider, child) {
                      if (ticketProvider.error.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: redErrorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: redErrorColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error,
                                  color: redErrorColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ticketProvider.error,
                                    style:
                                        const TextStyle(color: redErrorColor),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () {
                                    ticketProvider.clearError();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const TicketASection(),
                  const SizeboxTemplate(),
                  const TicketBSection(),
                  const SizeboxHeight(),
                  const RequestSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* 
1ere proposition avec dynamisation
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/buyTicket/requestSection.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticketASection.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticketBSection.dart';
import 'package:senticket_front/UI/widgets/home/sizebox.height.dart';
import 'package:senticket_front/UI/widgets/home/sizebox.template.dart';
import 'package:senticket_front/provider/ticket_provider.dart';

class BuyTicketBody extends StatefulWidget {
  const BuyTicketBody({super.key});

  @override
  State<BuyTicketBody> createState() => _BuyTicketBodyState();
}

class _BuyTicketBodyState extends State<BuyTicketBody> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    return ChangeNotifierProvider(
      create: (context) => TicketProvider(TicketApiService()),
      child: Background(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 0),
            child: SizedBox(
              width: size.width,
              child: Column(
                children: [
                  Consumer<TicketProvider>(
                    builder: (context, ticketProvider, child) {
                      // Afficher les erreurs globales
                      if (ticketProvider.error.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: errorColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error,
                                  color: errorColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ticketProvider.error,
                                    style: const TextStyle(color: errorColor),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () {
                                    ticketProvider.clearError();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const TicketASection(),
                  const SizeboxTemplate(),
                  const TicketBSection(),
                  const SizeboxHeight(),
                  const RequestSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} */