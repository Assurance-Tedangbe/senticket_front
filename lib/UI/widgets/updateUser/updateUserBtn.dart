import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/provider/user_provider.dart';

class UpdateUserBtn extends StatelessWidget {
  final VoidCallback onUpdateSuccess;

  const UpdateUserBtn({
    super.key,
    required this.onUpdateSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 25),
          width: double.infinity,
          height: 90,
          child: ElevatedButton(
            onPressed:
                userProvider.isUpdatingUser || !userProvider.isUpdateFormValid
                    ? null
                    : () async {
                        final success = await userProvider.submitUpdate();
                        if (success) {
                          // Afficher un message de succès
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Compte modifié avec succès !'),
                              backgroundColor: validateBtnColor,
                            ),
                          );

                          // Navigation ou callback
                          onUpdateSuccess();
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
                  userProvider.isUpdateFormValid && !userProvider.isUpdatingUser
                      ? kPrimaryColor
                      : Colors.grey,
              shape: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              textStyle: const TextStyle(
                color: kSecondColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: userProvider.isUpdatingUser
                ? const CircularProgressIndicator(color: kSecondColor)
                : const Text('Modifier'),
          ),
        );
      },
    );
  }
}

/* class UpdateUserBtn extends StatefulWidget {
  const UpdateUserBtn({super.key});

  @override
  State<UpdateUserBtn> createState() => _UpdateUserBtnState();
}

class _UpdateUserBtnState extends State<UpdateUserBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
        width: double.infinity,
        height: 90,
        child: ElevatedButton(
          onPressed: () => print('update pressed'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            shape: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            textStyle: const TextStyle(
                color: kSecondColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: const Text('Modifier'),
        ));
  }
} */
