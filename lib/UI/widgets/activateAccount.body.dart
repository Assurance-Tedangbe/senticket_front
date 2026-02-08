import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/deactivateAccount.dart';
import 'package:senticket_front/UI/pages/home.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizebox.height.dart';
import 'package:senticket_front/UI/widgets/updateUser/pageIconTemplate.dart';
import 'package:senticket_front/constants.dart';

class ActivateAccountBody extends StatefulWidget {
  const ActivateAccountBody({super.key});

  @override
  State<ActivateAccountBody> createState() => _ActivateAccountBodyState();
}

class _ActivateAccountBodyState extends State<ActivateAccountBody> {
  @override
  Widget build(BuildContext context) {
    Widget activationBtnAnimated() {
      return AnimatedButton(
        text: "Activer compte",
        color: kPrimaryColor,
        width: 290,
        height: 90,
        pressEvent: () {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            showCloseIcon: true,
            title: "Succès",
            desc: "compte active",
            btnOkOnPress: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => Home())),
          ).show();
        },
      );
    }

    Widget manageActivateBtn() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
        width: 320,
        height: 95,
        child: ElevatedButton(
          onPressed: () {},
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
          child: const Text('Activer compte'),
        ),
      );
    }

    return Background(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const PageIconTemplate(iconData: Icons.account_circle),
            const SizeboxHeight(),
            manageNumberAccount(),
            const SizeboxHeight(),
            //  manageActivateBtn(),
            activationBtnAnimated(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  iconSize: 40,
                  icon: const Icon(Icons.no_accounts, color: kPrimaryColor),
                  tooltip: 'désactiver compte',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DeactivateAccount(),
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
      const Text(
        'N° compte etudiant',
        style: TextStyle(color: kThirdColor, fontSize: 15),
      ),
      const SizedBox(height: 10),
      Container(
        width: 290,
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
