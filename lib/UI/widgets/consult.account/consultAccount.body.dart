import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/consult.account/consult.data.dart';
import 'package:senticket_front/UI/widgets/consult.account/consultBtn.dart';
import 'package:senticket_front/UI/widgets/consult.account/usernameConsultSection.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizebox.template.dart';
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

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
                    const SizeboxTemplate(),
                    ConsultBtn(
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
