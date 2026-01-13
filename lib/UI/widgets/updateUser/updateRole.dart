import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.credit/label.dart';
import 'package:senticket_front/UI/widgets/updateUser/SizeboxBtwLabelField.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:senticket_front/provider/role_privider.dart';
import 'package:senticket_front/model/role_model.dart';
import 'package:provider/provider.dart';

class UpdateRole extends StatelessWidget {
  final ValueChanged<Role?> onRoleChanged;
  final Role? selectedRole;

  const UpdateRole({
    super.key,
    required this.onRoleChanged,
    this.selectedRole,
  });

  Role? _getSelectedRole(List<Role> availableRoles, Role? selectedRole) {
    if (selectedRole == null) return null;

    // Chercher le rôle correspondant dans la liste disponible
    final matchingRole = availableRoles.firstWhere(
      (role) => role.roleId == selectedRole.roleId,
      orElse: () => Role(roleId: -1, roleName: ''), // Rôle fictif si non trouvé
    );

    // Si trouvé, retourner le rôle de la liste (même instance)
    if (matchingRole.roleId != -1) {
      return matchingRole;
    }

    // Si le rôle n'est pas dans la liste, retourner null
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleProvider>(
      builder: (context, roleProvider, child) {
        if (roleProvider.roles.isEmpty && !roleProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<RoleProvider>(context, listen: false).loadAllRoles();
          });
        }

        // Debug: Afficher les rôles disponibles et le rôle sélectionné
        print('🔄 Rôles disponibles: ${roleProvider.roles.length}');
        for (var role in roleProvider.roles) {
          print('   - ${role.roleName} (ID: ${role.roleId})');
        }
        print(
            '🎯 Rôle sélectionné: ${selectedRole?.roleName} (ID: ${selectedRole?.roleId})');

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
                child: roleProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kPrimaryColor,
                        ),
                      )
                    : DropdownButtonFormField<Role>(
                        value:
                            _getSelectedRole(roleProvider.roles, selectedRole),
                        /* selectedRole ??
                            (roleProvider.roles.isNotEmpty
                                ? roleProvider.roles.first
                                : null), */
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
                          onRoleChanged(value);
                          if (value != null) {
                            final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false);
                            userProvider.setUpdateRole(value);
                          }
                        },
                        items: roleProvider.roles
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

/* class UpdateRole extends StatefulWidget {
  const UpdateRole({super.key});

  @override
  State<UpdateRole> createState() => _UpdateRoleState();
}

class _UpdateRoleState extends State<UpdateRole> {
  TextEditingController roleController = TextEditingController();
  String roleSelected = 'Etudiant';
  var items = ['Etudiant', 'Agent', 'Portier', 'Admministarateur'];
  @override
  Widget build(BuildContext context) {
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
                    color: boxshadowColor, blurRadius: 6, offset: Offset(0, 2))
              ],
              border: Border.all(color: kPrimaryColor, width: 3)),
          height: 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
            child: DropdownButtonFormField<String>(
              value: roleSelected,
              iconDisabledColor: kThirdColor,
              iconEnabledColor: kPrimaryColor,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              onChanged: (String? value) {
                setState(() {
                  roleSelected = value!;
                  if (roleSelected == true) {
                    print(roleSelected);
                    // String kw = roleSelected;
                    // context
                    //      .read<HistoricBloc>()
                    //      .add(SearchHistoricEvent(keyword: kw));
                  }
                });
              },
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          color: kThirdColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        )
      ],
    );
  }
} */
