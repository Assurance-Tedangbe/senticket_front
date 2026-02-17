/* import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/constants.dart';

class AmountSection extends StatefulWidget {
  const AmountSection({super.key});

  @override
  State<AmountSection> createState() => _AmountSectionState();
}

class _AmountSectionState extends State<AmountSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Label(text: 'Montant'),
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
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(color: kPrimaryColor, width: 3),
          ),
          child: const TextField(
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(Icons.attach_money, color: kPrimaryColor),
              hintText: 'Montant',
              hintStyle: TextStyle(color: kPrimaryColor, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
 */
