import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/buyTicket/buyticket.body.dart';
import 'package:senticket_front/constants.dart';

class BuyTicket extends StatelessWidget {
  static const String _title = 'Acheter ticket';
  const BuyTicket({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text(_title), backgroundColor: kPrimaryColor),
      body: const BuyTicketBody(),
    );
  }
}
