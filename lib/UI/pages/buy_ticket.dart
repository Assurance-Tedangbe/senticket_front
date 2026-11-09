import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/buyTicket/buyticket.body.dart';
import 'package:senticket_front/constants.dart';
import '../../provider/payment_provider.dart';
import '../../provider/purchase_cart_provider.dart';
import '../../services/payment_service.dart';

class BuyTicket extends StatelessWidget {
  static const String _title = 'Acheter ticket';
  const BuyTicket({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PurchaseCartProvider()),
          ChangeNotifierProvider(create: (_) => PaymentProvider(PaymentApiService())),
        ],
        child:
      Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text(_title), backgroundColor: kPrimaryColor),
      body: const BuyTicketBody(),
    )
    );
  }
}
