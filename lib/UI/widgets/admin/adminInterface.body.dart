import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/admin/admin.services.dart';

class AdminBody extends StatelessWidget {
  const AdminBody({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: const Column(children: [AdminServices()]),
        ),
      ),
    );
  }
}
