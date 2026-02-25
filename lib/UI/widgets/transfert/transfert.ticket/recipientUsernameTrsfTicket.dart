import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/constants.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/provider/user_provider.dart';

class RecipientUsernameTrsfTicket extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const RecipientUsernameTrsfTicket({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
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
                border: Border.all(color: kPrimaryColor, width: 1),
              ),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: enterTextFieldColor),
                onChanged: (value) {
                  userProvider.setTransferRecipientUsername(value);
                  onChanged?.call(value);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(top: 14),
                  prefixIcon: const Icon(Icons.person, color: kPrimaryColor),
                  hintText: 'Nom d\'utilisateur destinataire',
                  hintStyle: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 12,
                  ),
                  errorText: userProvider.transferRecipientError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/* class RecipientUsernameTrsfTicket extends StatefulWidget {
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
} */
