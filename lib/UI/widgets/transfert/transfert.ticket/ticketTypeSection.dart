import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.credit/label.dart';
import 'package:senticket_front/constants.dart';

class TicketTypeSection extends StatefulWidget {
  const TicketTypeSection({super.key});

  @override
  State<TicketTypeSection> createState() => _TicketTypeSectionState();
}

class _TicketTypeSectionState extends State<TicketTypeSection> {
  bool istypeA = false;
  bool istypeB = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(children: [
        Theme(
          data: ThemeData(unselectedWidgetColor: kPrimaryColor),
          child: Checkbox(
              value: istypeA,
              checkColor: kSecondColor,
              activeColor: kPrimaryColor,
              onChanged: (value) {
                setState(() {
                  istypeA = value!;
                });
              }),
        ),
        const Label(text: 'Type A'),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
          child: Theme(
            data: ThemeData(unselectedWidgetColor: kPrimaryColor),
            child: Checkbox(
                value: istypeA,
                checkColor: kSecondColor,
                activeColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    istypeB = value!;
                  });
                }),
          ),
        ),
        const Label(text: 'Type B'),
      ]),
    );
  }
}
