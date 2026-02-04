import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class AccessDebitPageBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFormValid;

  const AccessDebitPageBtn({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.isFormValid = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      width: 320,
      height: 95,
      child: ElevatedButton(
        onPressed: isLoading || !isFormValid ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid && !isLoading
              ? kPrimaryColor
              : greyBorderColor,
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          textStyle: const TextStyle(
            color: kSecondColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: kSecondColor)
            : const Text('Valider'),
      ),
    );
  }
}

/* import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';

/*
  Widget pour le bouton d'accès à la page de débit de compte.
  Dynamiquement activé/désactivé selon la validation du formulaire.
*/
class AccessDebitPageBtn extends StatelessWidget {
  final void Function(int userId) onFormSuccess; // ← Correction ici

  const AccessDebitPageBtn({super.key, required this.onFormSuccess});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
          width: 320,
          height: 95,
          child: ElevatedButton(
            onPressed:
                userProvider.isDebitingUser || !userProvider.isDebitFormValid
                ? null
                : () async {
                    final success = await userProvider.accessDebitPage();
                    if (success) {
                      // Récupérer l'ID de l'utilisateur courant
                      final userId = userProvider.currentUser?.userId;
                      if (userId != null) {
                        onFormSuccess(userId); // ← Appel avec userId
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erreur: ID utilisateur non trouvé'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      // Afficher l'erreur
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(userProvider.error),
                          backgroundColor: redErrorColor,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  userProvider.isDebitFormValid && !userProvider.isDebitingUser
                  ? kPrimaryColor
                  : greyBorderColor,
              shape: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              textStyle: const TextStyle(
                color: kSecondColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: userProvider.isConsultingUser
                ? const CircularProgressIndicator(color: kSecondColor)
                : const Text('Valider'),
          ),
        );
      },
    );
  }
}

/* class DebitValidateBtn extends StatefulWidget {
  const DebitValidateBtn({super.key});

  @override
  State<DebitValidateBtn> createState() => _DebitValidateBtnState();
}

class _DebitValidateBtnState extends State<DebitValidateBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      width: 320,
      height: 95,
      child: ElevatedButton(
        onPressed: () => print('validate pressed'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          textStyle: const TextStyle(
              color: kSecondColor, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        child: const Text('Valider'),
      ),
    );
  }
} */
 */
