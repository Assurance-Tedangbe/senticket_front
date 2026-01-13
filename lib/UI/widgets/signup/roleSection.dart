import 'package:flutter/material.dart';
import 'package:senticket_front/provider/role_privider.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.credit/label.dart';
import 'package:senticket_front/UI/widgets/updateUser/SizeboxBtwLabelField.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/model/role_model.dart';

/*
  Widget pour la sélection du rôle avec données chargées depuis l'API.
  Utilise le RoleProvider pour récupérer la liste des rôles disponibles.
*/
class RoleSection extends StatelessWidget {
  // ⭐ CHANGEMENT : Accepte un objet Role, pas un String
  final ValueChanged<Role?> onRoleChanged; // ← ICI
  final Role? selectedRole; // ⭐ NOUVEAU : Pour garder la sélection

  const RoleSection({
    super.key,
    required this.onRoleChanged, // ← ICI
    this.selectedRole, // ⭐ NOUVEAU
  });

  /* Consumer est utilisé QUAND ON A BESOIN DE "LIRE" DES DONNÉES DYNAMIQUES
     Ce widget a besoin d'accéder à des données dynamiques du Provider :
     roleProvider.roles  */

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleProvider>(
      // Consumer permet de réagir aux changements du Provider  // ← ICI
      builder: (context, roleProvider, child) {
        // Vérifie si les rôles sont chargés, sinon les charge
        if (roleProvider.roles.isEmpty && !roleProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<RoleProvider>(context, listen: false).loadAllRoles();
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Label(text: 'Rôle'),
            const SizeBoxBtwLabelField(),
            Container(
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
              height: 50,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
                child: roleProvider.isLoading // ← ICI
                    ? // Affiche un indicateur de chargement pendant le chargement
                    const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kPrimaryColor,
                        ),
                      )
                    : // Affiche la liste déroulante une fois les données chargées
                    DropdownButtonFormField<Role>(
                        // ⭐ CHANGEMENT : Utilise la valeur sélectionnée
                        value: roleProvider.roles.isNotEmpty
                            ? roleProvider.roles.first
                            : null,
                        iconDisabledColor: kThirdColor,
                        iconEnabledColor: kPrimaryColor,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: kThirdColor,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(bottom: 10),
                        ),
                        onChanged: (Role? value) {
                          onRoleChanged(
                              value); // ⭐ CHANGEMENT : Passe l'objet Role

                          // ⭐ EN PLUS : Mettez à jour le UserProvider
                          if (value != null) {
                            final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false);
                            userProvider.setRole(value);
                            print(
                                '✅ Rôle sélectionné: ${value.roleName} (ID: ${value.roleId})');
                          }
                        },
                        items: roleProvider.roles // ← ICI
                            .map<DropdownMenuItem<Role>>((Role role) {
                          return DropdownMenuItem<Role>(
                            value: role,
                            child: Text(
                              role.roleName,
                              style: const TextStyle(color: kThirdColor),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
