import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/admin/agent.mgmt.dart/listAgents.dart';

class ManageAgentBody extends StatelessWidget {
  const ManageAgentBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: const Column(children: [
          ListAgentsPage(),
        ]),
      ),
    );
  }
}
