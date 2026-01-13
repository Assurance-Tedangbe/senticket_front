import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/consult.account/consult.data.dart';
import 'package:senticket_front/UI/widgets/consult.account/consultBtn.dart';
import 'package:senticket_front/UI/widgets/consult.account/usernameConsultSection.dart';
import 'package:senticket_front/UI/widgets/home/sizebox.template.dart';
import 'package:senticket_front/UI/widgets/updateUser/pageIconTemplate.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';

/*
  Widget principal pour la consultation de compte.
  StatefulWidget pour gérer le contrôleur du champ nom d'utilisateur.
*/
class ConsultBody extends StatefulWidget {
  const ConsultBody({super.key});

  @override
  State<ConsultBody> createState() => _ConsultBodyState();
}

class _ConsultBodyState extends State<ConsultBody> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  /* void _onConsultSuccess() {
    // Navigation vers la page d'affichage des données
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ConsultData()),
    );
  } */

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Icône de la page
            const PageIconTemplate(iconData: Icons.search),
            const SizedBox(height: 20),

            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Column(
                  children: [
                    UsernameConsultSection(
                      controller: _usernameController,
                      onChanged: (value) =>
                          userProvider.setConsultUsername(value),
                    ),
                    //const SizedBox(height: 20),
                    const SizeboxTemplate(),
                    ConsultBtn(
                      // onConsultSuccess: _onConsultSuccess,
                      onConsultSuccess: (int userId) {
                        // Naviguer vers ConsultData avec l'ID de l'utilisateur
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ConsultData(userId: userId),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
