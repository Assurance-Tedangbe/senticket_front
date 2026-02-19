import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/constants.dart';

class RecipientUsernameTrsfTicket extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const RecipientUsernameTrsfTicket({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  State<RecipientUsernameTrsfTicket> createState() =>
      _RecipientUsernameTrsfTicketState();
}

class _RecipientUsernameTrsfTicketState
    extends State<RecipientUsernameTrsfTicket> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Label(text: 'Nom d\'utilisateur destinataire'),
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
            border: Border.all(color: kPrimaryColor, width: 2),
          ),
          child: TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            keyboardType: TextInputType.text,
            style: const TextStyle(color: enterTextFieldColor),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(Icons.person, color: kPrimaryColor),
              hintText: 'Nom d\'utilisateur destinataire',
              hintStyle: TextStyle(color: kPrimaryColor, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

/* class RecipientUsernameTrsfTicket extends StatefulWidget {
  const RecipientUsernameTrsfTicket({super.key});

  @override
  State<RecipientUsernameTrsfTicket> createState() =>
      _RecipientUsernameTrsfTicketState();
}

class _RecipientUsernameTrsfTicketState
    extends State<RecipientUsernameTrsfTicket> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Label(text: 'Nom d\'utilisateur destinataire'),
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
            border: Border.all(color: kPrimaryColor, width: 2),
          ),
          child: const TextField(
            keyboardType: TextInputType.number,
            style: TextStyle(color: enterTextFieldColor),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(Icons.person, color: kPrimaryColor),
              hintText: 'Nom d\'utilisateur destinataire',
              hintStyle: TextStyle(color: kPrimaryColor, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
} */
