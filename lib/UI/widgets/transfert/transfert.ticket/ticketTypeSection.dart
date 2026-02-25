/* import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/constants.dart';

class NumberTicketsSection extends StatelessWidget {
  final TextEditingController controller;

  const NumberTicketsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(Icons.attach_money, color: kPrimaryColor),
              hintText: 'Nombre de ticket',
              hintStyle: TextStyle(color: kPrimaryColor, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

/* 
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
      child: Row(
        children: [
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
              },
            ),
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
                },
              ),
            ),
          ),
          const Label(text: 'Type B'),
        ],
      ),
    );
  }
} */
 */
