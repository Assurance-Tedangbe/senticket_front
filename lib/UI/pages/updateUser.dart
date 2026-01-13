import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/updateUser/updateUserBody.dart';

class UpdateUser extends StatelessWidget {
  static const String _title = 'Modifier un utilisateur';
  // Vous pouvez garder ce paramètre si vous voulez passer l'ID
  final int? userId;
  const UpdateUser({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text(_title)),
        body: const UpdateUserBody());
  }
}
