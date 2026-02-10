import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/UI/widgets/updateUser/SizeboxBtwLabelField.dart';
import 'package:senticket_front/constants.dart';

class UpdateLastName extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const UpdateLastName({super.key, required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Label(text: 'Nom'),
        const SizeBoxBtwLabelField(),
        Container(
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
          height: 50,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.text,
            style: const TextStyle(color: enterTextFieldColor),
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 11),
              prefixIcon: Icon(Icons.person, color: kPrimaryColor),
              hintText: 'Nom',
              hintStyle: TextStyle(color: kPrimaryColor, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

/* class UpdateLastName extends StatefulWidget {
  const UpdateLastName({super.key});

  @override
  State<UpdateLastName> createState() => _UpdateLastNameState();
}

class _UpdateLastNameState extends State<UpdateLastName> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Label(text: 'Nom'),
        const SizeBoxBtwLabelField(),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: kSecondColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                    color: boxshadowColor, blurRadius: 6, offset: Offset(0, 2))
              ],
              border: Border.all(color: kPrimaryColor, width: 3)),
          height: 50,
          child: const TextField(
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: enterTextFieldColor,
            ),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 11),
                prefixIcon: Icon(Icons.person, color: kPrimaryColor),
                hintText: 'Nom',
                hintStyle: TextStyle(color: kPrimaryColor, fontSize: 12)),
          ),
        )
      ],
    );
  }
} */
