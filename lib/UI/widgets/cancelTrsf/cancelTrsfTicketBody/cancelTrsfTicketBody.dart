import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/cancelTrsf/cancelTrsfTicketBody/cancelTrsfTicketBtn.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizeboxHeightSession.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.ticket/numberTicketsSection.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.ticket/senderPasswordTrsfTicket.dart';

class CancelTrsfTicketBody extends StatelessWidget {
  const CancelTrsfTicketBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Background(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizeboxHeightSession(),
            SizeboxHeightSession(),
            CancelTrsfTicketBtn(),
          ],
        ),
      ),
    );
  }
}
