import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/updateProfile.body.dart';

class UpdateProfile extends StatelessWidget {
  static const String _title = 'Mettre à jour son profile';
  const UpdateProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text(_title)),
        body: const UpdateProfileBody());
  }
}
