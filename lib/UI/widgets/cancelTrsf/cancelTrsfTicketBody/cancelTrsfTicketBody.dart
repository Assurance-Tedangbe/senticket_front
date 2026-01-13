import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/cancelTrsf/cancelTrsfTicketBody/cancelTrsfTicketBtn.dart';
import 'package:senticket_front/UI/widgets/cancelTrsf/cancelTrsfTicketBody/referenceNumberCancelTrsfTicketSection.dart';
import 'package:senticket_front/UI/widgets/home/sizeboxHeightSession.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.ticket/numberTicketsSection.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.ticket/passwordTrsfTicketSection.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.ticket/recipientNumberTrsfTicketSection.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.ticket/ticketTypeSection.dart';

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
            ReferenceNumberCancelTrsfTicketSection(),
            SizeboxHeightSession(),
            RecipientNumberTrsfTicketSection(),
            SizeboxHeightSession(),
            NumberTicketsSection(),
            SizeboxHeightSession(),
            Padding(
              padding: EdgeInsets.fromLTRB(25.0, 0.0, 8.0, 0.0),
              child: TicketTypeSection(),
            ),
            SizeboxHeightSession(),
            PasswordTrsfTicketSection(),
            SizeboxHeightSession(),
            CancelTrsfTicketBtn()
          ],
        ),
      ),
    );
  }
}
