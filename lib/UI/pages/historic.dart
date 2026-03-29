import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/historic/historic.body.dart';
import 'package:senticket_front/constants.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/provider/transaction_history_provider.dart';
import 'package:senticket_front/services/transaction_history_api_service.dart';

/// Page d'historique des transactions
class Historic extends StatelessWidget {
  static const String _title = 'Historique';

  const Historic({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionHistoryProvider(TransactionHistoryApiService()),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text(_title),
          backgroundColor: kPrimaryColor,
        ),
        body: const HistoricBody(),
      ),
    );
  }
}

/* class Historic extends StatelessWidget {
  static const String _title = 'Historique';
  const Historic({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text(_title), backgroundColor: kPrimaryColor),
      body: HistoricBody(),
    );
  }
}
 */
