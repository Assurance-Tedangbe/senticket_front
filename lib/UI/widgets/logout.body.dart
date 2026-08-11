import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/coverPage.dart';
import 'package:senticket_front/UI/pages/home.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizebox.template.dart';
import 'package:senticket_front/UI/widgets/updateUser/pageIconTemplate.dart';
import 'package:senticket_front/constants.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/provider/user_provider.dart';

class LogOutBody extends StatefulWidget {
  const LogOutBody({super.key});

  @override
  State<LogOutBody> createState() => _LogOutBodyState();
}

class _LogOutBodyState extends State<LogOutBody> {
  bool _isLoggingOut = false;

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
              onPressed: () =>
             // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Home()))
              () {  Navigator.of(context).pop(); }),
            TextButton(
              child: const Text('OUI'),
              onPressed: () async {
                Navigator.of(context).pop(); // Fermer le dialog

                setState(() => _isLoggingOut = true);

                // VRAI LOGOUT : supprime le token JWT
                // et réinitialise l'état utilisateur
                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );
                await userProvider.logout();

                if (!context.mounted) return;

                // Retour à la page de couverture
                // pushAndRemoveUntil vide la pile de navigation
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const CoverPage()),
                      (route) => false,
                );
              },
            ),
            /*TextButton(
              child: const Text('OUI'),
              onPressed: () =>
               Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CoverPage())),
            ),*/
          ],
        );
      },
    );
  }

  Widget _logoutBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25),
      height: 100,
      width: 170,
      child: ElevatedButton(
        onPressed: _isLoggingOut ? null : _showAlertDialog,
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
        child: _isLoggingOut
            ? const CircularProgressIndicator(color: kPrimaryColor)
            : const Text(
          'Se déconnecter',
          style: TextStyle(color: kSecondColor),
        ),
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
            _logoutBtn(),
          ],
        ),
      ),
    );
  }
}
