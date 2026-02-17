/* import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/constants.dart';

class ReferenceNumberSection extends StatefulWidget {
  const ReferenceNumberSection({super.key});

  @override
  State<ReferenceNumberSection> createState() => _ReferenceNumberSectionState();
}

class _ReferenceNumberSectionState extends State<ReferenceNumberSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Label(text: 'N° de référence'),
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
            border: Border.all(color: kPrimaryColor, width: 3),
          ),
          child: const TextField(
            // keyboardType: TextInputType.number,
            style: TextStyle(color: enterTextFieldColor),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(Icons.person, color: kPrimaryColor),
              hintText: 'N° de référence',
              hintStyle: TextStyle(color: kPrimaryColor, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
 */
