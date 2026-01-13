import 'package:flutter/material.dart';

class HomeDrawerItemWidget extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final Function onAction;

  const HomeDrawerItemWidget(
      {Key? key,
      required this.title,
      required this.leadingIcon,
      required this.trailingIcon,
      required this.onAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      leading: Icon(
        leadingIcon,
        color: Theme.of(context).primaryColor,
        //   size: 40,
      ),
      trailing: Icon(
        trailingIcon,
        color: Theme.of(context).primaryColor,
      ),
      /*
      CircleAvatar(
          radius: 40,
          child: Image.asset(leadingIcon, width: 25.0, height: 25.0)),
      */
      onTap: (() => onAction()),
    );
  }
}
