import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/research.dart/resaerach.listTile.dart';

class ResearchListView extends StatelessWidget {
  // List<dynamic> services;
  const ResearchListView({
    super.key,
    //  required this.services
  });

  @override
  Widget build(BuildContext context) {
    List<dynamic> services = [
      {
        "title": "Acheter ticket",
        "route": "/ticket",
        "leadingIcon": "images/ticket.JPG"
      },
      {
        "title": "Activer compte",
        "route": "/activate-account",
        "leadingIcon": "images/graphic.png"
      },
      {
        "title": "Annuler recharge",
        "route": "/cancel-recharge",
        "leadingIcon": "images/annuler_transaction.JPG"
      },
      {
        "title": "Annuler transfert crédit",
        "route": "/cancel-transfert-credit",
        "leadingIcon": "images/annuler_transaction.JPG"
      },
      {
        "title": "Annuler transfert ticket",
        "route": "/cancel-transfert-ticket",
        "leadingIcon": "images/annuler_transaction.JPG"
      },
      {
        "title": "Créditer compte",
        "route": "/credit-account",
        "leadingIcon": "images/crediter.JPG"
      },
      {
        "title": "Consulter compte",
        "route": "/consult-account",
        "leadingIcon": "images/graphic.png"
      },
      {
        "title": "Débiter compte",
        "route": "/debit-account",
        "leadingIcon": "images/debiter.JPG"
      },
      {
        "title": "Désactiver compte",
        "route": "/deactivate-account",
        "leadingIcon": "images/graphic.png"
      },
      {
        "title": "Mise à jour profil",
        "route": "/update-profile",
        "leadingIcon": "images/update_profile.JPG"
      },
      {
        "title": "Scan QR code",
        "route": "/scanQR",
        "leadingIcon": "images/scan.JPG"
      },
      {
        "title": "Transfert crédit",
        "route": "/transfert-credit",
        "leadingIcon": "images/transfert.JPG"
      },
      {
        "title": "Transfert ticket",
        "route": "/transfert-ticket",
        "leadingIcon": "images/transfert.JPG"
      },
    ];
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
              itemBuilder: (context, index) {
                return ResearchListTile(
                    title: services[index]['title'],
                    leadingIcon: services[index]['leadingIcon'],
                    onAction: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, services[index]['route']);
                    });
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  height: 2,
                );
              },
              itemCount: services.length),
        ),
      ],
    );
  }
}
