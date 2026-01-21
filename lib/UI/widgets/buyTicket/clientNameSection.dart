import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class ClientNameSection extends StatefulWidget {
  final Function(String)? onChanged;
  final String? initialValue;

  const ClientNameSection({super.key, this.onChanged, this.initialValue});

  @override
  State<ClientNameSection> createState() => _ClientNameSectionState();
}

class _ClientNameSectionState extends State<ClientNameSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // const Label(text: "Nom de l'acheteur"),
          // const SizedBox(height: 5),
          Container(
            width: size.width * 0.50,
            height: size.height / 14.0,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: ticketSectionColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: boxshadowColor,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
              border: Border.all(color: kPrimaryColor, width: 1),
            ),
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              keyboardType: TextInputType.text,
              style: const TextStyle(color: enterTextFieldColor, fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                prefixIcon: Icon(Icons.person, color: Colors.black54),
                hintText: "Entrez le nom de l'acheteur",
                hintStyle: TextStyle(color: enterTextFieldColor, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* Impl. sans dynamisation
class ClientNameSection extends StatefulWidget {
  const ClientNameSection({super.key});

  @override
  State<ClientNameSection> createState() => _ClientNameSectionState();
}

class _ClientNameSectionState extends State<ClientNameSection> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Label(text: "Nom de l'acheteur"),
          const SizedBox(height: 5),
          Container(
            width: size.width * 0.50,
            height: size.height / 14.0,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: ticketSectionColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                      color: boxshadowColor,
                      blurRadius: 6,
                      offset: Offset(0, 2))
                ],
                border: Border.all(color: kPrimaryColor, width: 1)),
            child: const TextField(
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: enterTextFieldColor,
              ),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 9, bottom: 15),
                  prefixIcon: Icon(Icons.person, color: Colors.black54),
                  hintText: "Acheteur",
                  hintStyle: TextStyle(
                    color: enterTextFieldColor,
                    fontSize: 11,
                  )),
            ),
          )
        ],
      ),
    );
  }
} */
