import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class ResearchListTile extends StatelessWidget {
  final String title;
  final String leadingIcon;
  final Function onAction;
  const ResearchListTile(
      {super.key,
      required this.title,
      required this.leadingIcon,
      required this.onAction});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      leading: CircleAvatar(
          radius: 40,
          backgroundColor: kSecondColor,
          child: Image.asset(leadingIcon, width: 25.0, height: 25.0)),
      onTap: (() => onAction()),
    );
  }
}
