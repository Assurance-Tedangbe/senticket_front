import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/debitAccount/debitAccount.body.dart';

class DebitAccount extends StatelessWidget {
  static const String _title = 'Débiter un compte';
  const DebitAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text(_title)),
      body: const DebitBody(),
    );
  }
}

/* class DebitAccount extends StatelessWidget {
  static const String _title = 'Débiter un compte';
  const DebitAccount({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Vérifier si l'utilisateur a le rôle PORTIER
        if (userProvider.currentUser?.role.name != 'PORTIER') {
          return Scaffold(
            appBar: AppBar(title: const Text('Accès refusé')),
            body: Padding(
              padding: EdgeInsets.only(
                top: size.height * 0.3,
                left: size.width * 0.15,
                right: size.width * 0.15,
              ),
              child: Container(
                alignment: Alignment.center,
                height: size.height * 0.09,
                width: size.width * 0.7,
                decoration: BoxDecoration(
                  color: textContainerColor,
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
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Seuls les utilisateurs PORTIER peuvent accéder à cette page.",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(title: const Text(_title)),
          body: const DebitBody(),
        );
      },
    );
  }
}  */
