import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/ticket_provider.dart';

class NumberTicketsSection extends StatelessWidget {
  final TextEditingController controller;
  // final ValueChanged<String>? onChanged;

  const NumberTicketsSection({
    super.key,
    required this.controller,
    // this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Label(text: 'Nombre de ticket'),
            const SizedBox(height: 10),
            Container(
              width: 300,
              height: 50,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: kSecondColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: boxshadowColor,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(color: kPrimaryColor, width: 1),
              ),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: enterTextFieldColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(top: 14),
                  prefixIcon: const Icon(
                    Icons.attach_money,
                    color: kPrimaryColor,
                  ),
                  hintText: 'Nombre de ticket',
                  hintStyle: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 12,
                  ),
                  errorText: ticketProvider.numberOfTicketsError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
