import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class SoldeSection extends StatefulWidget {
  const SoldeSection({super.key});

  @override
  State<SoldeSection> createState() => _SoldeSectionState();
}

class _SoldeSectionState extends State<SoldeSection> {
//LocalStorage storage = LocalStorage('user_information');
//  bool isVisible = false;
  // String defaultValue = "----------";
//  String solde = "";
  String afficher = "- - - - ";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          width: size.width,
          height: size.height / 6.5,
          decoration: const BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.all(Radius.circular(17.0))),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Solde",
                style: TextStyle(
                    color: kThirdColor,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w700),
              ),
              const Text(
                "- - - -",
                style: TextStyle(
                    color: kThirdColor,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: size.height / 22.0,
                width: size.width / 12.0,
                decoration: const BoxDecoration(
                    color: kThirdColor,
                    borderRadius: BorderRadius.all(Radius.circular(50.0))),
                child: IconButton(
                    onPressed: () {},
                    /*  () async {
                Map response = await SellBtcService().getBalance();
                if (response['solde'] == '0E-8') {
                  storage.setItem('solde', '0.00000');
                } else {
                  storage.setItem('solde', response['solde']);
                }
        
                setState(() {
                  isVisible = !isVisible;
                  if (isVisible) {
                    afficher = '${storage.getItem('solde')}';
                  } else {
                    afficher = defaultValue;
                  }
                });
              },*/
                    icon: const Icon(
                      Icons.visibility_off,
                      //  isVisible ? Icons.visibility : Icons.visibility_off,
                      color: kSecondColor,
                    )),
              )
            ],
          ),
        ),
      ],
    );
  }
}
