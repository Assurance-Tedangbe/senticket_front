import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/coverPage.dart';
import 'package:senticket_front/UI/pages/home.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizebox.template.dart';
import 'package:senticket_front/UI/widgets/updateUser/pageIconTemplate.dart';
import 'package:senticket_front/constants.dart';

class LogOutBody extends StatefulWidget {
  const LogOutBody({super.key});

  @override
  State<LogOutBody> createState() => _LogOutBodyState();
}

class _LogOutBodyState extends State<LogOutBody> {
  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Etes-vous sûr de vouloir vous déconnecter'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ANNULER'),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => const Home())),
              //() {  Navigator.of(context).pop();},
            ),
            TextButton(
              child: const Text('OUI'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CoverPage()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget logoutBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25),
      height: 100,
      width: 170,
      child: ElevatedButton(
        onPressed: _showAlertDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          textStyle: const TextStyle(
            color: kSecondColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text('Se déconnecter'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const PageIconTemplate(iconData: Icons.logout),
            const SizeboxTemplate(),
            logoutBtn(),
          ],
        ),
      ),
    );
  }
}
