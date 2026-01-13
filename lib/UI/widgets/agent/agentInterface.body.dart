import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/agent/agent.services.dart';

class AgentBody extends StatelessWidget {
  const AgentBody({super.key});

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
          child: const Column(children: [
            AgentServices(),
          ]),
        ),
      ),
    );
  }
}
