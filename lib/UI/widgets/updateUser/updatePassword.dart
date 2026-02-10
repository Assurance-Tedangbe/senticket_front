import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/UI/widgets/updateUser/SizeboxBtwLabelField.dart';
import 'package:senticket_front/constants.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/provider/user_provider.dart';

/* Option 2: Afficher un placeholder et un toggle pour montrer/cacher */
class UpdatePassword extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? initialPassword;

  const UpdatePassword({
    super.key,
    required this.controller,
    this.onChanged,
    this.initialPassword,
  });

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  bool _isPasswordVisible = false;
  bool _isPasswordChanged = false;

  @override
  void initState() {
    super.initState();

    // Initialiser avec placeholder si mot de passe existant
    if (widget.initialPassword != null && widget.initialPassword!.isNotEmpty) {
      widget.controller.text = '********'; // Placeholder
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                const Label(text: 'Mot de passe'),
                const SizedBox(width: 8),
                Text(
                  '(${_isPasswordChanged ? 'modifié' : 'actuel: ********'})',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isPasswordChanged ? Colors.green : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizeBoxBtwLabelField(),
            Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: kSecondColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: boxshadowColor,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(color: kPrimaryColor, width: 3),
              ),
              height: 50,
              child: TextFormField(
                controller: widget.controller,
                keyboardType: TextInputType.visiblePassword,
                obscureText: !_isPasswordVisible,
                style: const TextStyle(color: enterTextFieldColor),
                onChanged: (value) {
                  if (widget.onChanged != null) {
                    widget.onChanged!(value);
                  }

                  // Détecter si le mot de passe a été modifié
                  final isChanged = value != '********' && value.isNotEmpty;
                  if (isChanged != _isPasswordChanged) {
                    setState(() {
                      _isPasswordChanged = isChanged;
                    });
                  }

                  // Si l'utilisateur tape sur le placeholder, le vider
                  if (value == '********') {
                    widget.controller.clear();
                    if (widget.onChanged != null) {
                      widget.onChanged!('');
                    }
                  }
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 11),
                  prefixIcon: const Icon(Icons.password, color: kPrimaryColor),
                  hintText: _isPasswordChanged
                      ? 'Nouveau mot de passe'
                      : 'Tapez pour changer le mot de passe',
                  hintStyle: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 12,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Toggle pour montrer/cacher
                      IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: kPrimaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      // Bouton pour réinitialiser
                      if (_isPasswordChanged)
                        IconButton(
                          icon: const Icon(
                            Icons.undo,
                            color: Colors.orange,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              widget.controller.text = '********';
                              _isPasswordChanged = false;
                              _isPasswordVisible = false;
                              if (widget.onChanged != null) {
                                widget.onChanged!('');
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            // Message d'information
            if (!_isPasswordChanged)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: Text(
                  'Le mot de passe actuel est masqué pour sécurité',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
          ],
        );
      },
    );
  }
}

/* class UpdatePassword extends StatefulWidget {
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Label(text: 'Mot de passe'),
        const SizeBoxBtwLabelField(),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: kSecondColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                    color: boxshadowColor, blurRadius: 6, offset: Offset(0, 2))
              ],
              border: Border.all(color: kPrimaryColor, width: 3)),
          height: 50,
          child: const TextField(
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            style: TextStyle(
              color: enterTextFieldColor,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(top: 11),
              prefixIcon: Icon(Icons.password, color: kPrimaryColor),
              hintText: 'Mot de passe',
              hintStyle: TextStyle(
                color: kPrimaryColor,
                fontSize: 12,
              ),
              suffixIcon: Icon(
                Icons.visibility_off,
                color: kPrimaryColor,
              ),
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }
} */
