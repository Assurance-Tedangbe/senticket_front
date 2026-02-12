import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/cancelRecharge.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/constants.dart';

class CreditBody extends StatefulWidget {
  const CreditBody({super.key});

  @override
  State<CreditBody> createState() => _CreditBodyState();
}

class _CreditBodyState extends State<CreditBody> {
  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.attach_money, color: kPrimaryColor, size: 70),
            const SizedBox(height: 20),
            manageNumberAccount(),
            const SizedBox(height: 12),
            manageAmount(),
            const SizedBox(height: 12),
            manageRechargeBtn(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  iconSize: 60,
                  icon: const Icon(Icons.cancel, color: kPrimaryColor),
                  tooltip: 'Annuler recharge',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CancelRecharge(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget manageNumberAccount() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const Label(text: 'Numéro compte etudiant'),
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
          keyboardType: TextInputType.number,
          style: TextStyle(color: enterTextFieldColor),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14),
            prefixIcon: Icon(Icons.person, color: kPrimaryColor),
            hintText: 'N° compte etudiant',
            hintStyle: TextStyle(color: kPrimaryColor, fontSize: 12),
          ),
        ),
      ),
    ],
  );
}

Widget manageAmount() {
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
              color: boxshadowColor,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(color: kPrimaryColor, width: 3),
        ),
        child: const TextField(
          keyboardType: TextInputType.number,
          style: TextStyle(color: enterTextFieldColor),
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

Widget manageRechargeBtn() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
    width: 320,
    height: 95,
    child: ElevatedButton(
      onPressed: () => print('Credit pressed'),
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        textStyle: const TextStyle(
          color: kSecondColor,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: const Text('Créditer compte'),
    ),
  );
}
