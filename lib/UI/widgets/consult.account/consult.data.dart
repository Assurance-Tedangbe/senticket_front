import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/model/user_model.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';

/*
  Page d'affichage des informations du compte consulté.
*/
/* class ConsultData extends StatelessWidget {
  static const String _title = 'Informations sur le compte';
  final int userId;

  const ConsultData({super.key, required this.userId}); */
class ConsultData extends StatefulWidget {
  // static const String _title = 'Informations sur le compte';
  final int userId;

  const ConsultData({super.key, required this.userId});

  @override
  State<ConsultData> createState() => _ConsultDataState();
}

class _ConsultDataState extends State<ConsultData> {
  static const String _title = 'Informations sur le compte';

  @override
  void initState() {
    super.initState();
    // Charger l'utilisateur au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.loadUserById(widget.userId);
    });
  }

  // Méthode pour masquer le mot de passe
  String _maskPassword(String password) {
    if (password.isEmpty) return '********';
    return '*' * password.length; // Afficher 8 étoiles pour la sécurité
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text(_title), backgroundColor: kPrimaryColor),
      /* nous pouvons directement utiliser userProvider.currentUser 
         sans avoir besoin d'un FutureBuilder supplémentaire.  */
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && userProvider.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userProvider.currentUser; // ← Données déjà disponibles

          // Pas besoin de FutureBuilder car les données sont déjà dans le Provider
          return Background(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Carte principale des informations
                  Container(
                    alignment: Alignment.center,
                    width: size.width * 0.9,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: textContainerColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: boxshadowColor,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        // Icône utilisateur
                        const Icon(
                          Icons.account_circle,
                          size: 80,
                          color: kPrimaryColor,
                        ),
                        const SizedBox(height: 20),

                        if (user == null)
                          const Center(
                            child: Text(
                              'Aucune donnée utilisateur disponible',
                              style: TextStyle(
                                color: greyBorderColor,
                                fontSize: 16,
                              ),
                            ),
                          )
                        else
                          _buildUserInfo(user),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Bouton de retour
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Réinitialiser l'utilisateur courant si nécessaire
                      userProvider.clearCurrentUser();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Retour',
                      style: TextStyle(
                        color: kSecondColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget pour construire les informations utilisateur
  Widget _buildUserInfo(User user) {
    return Column(
      children: <Widget>[
        // ID utilisateur
        _buildInfoRow('ID', user.userId?.toString() ?? 'N/A'),
        const Divider(color: greyBorderColor),

        // Nom complet
        _buildInfoRow(
          'Nom complet',
          '${user.firstName} ${user.lastName}'.trim(),
        ),
        const Divider(color: greyBorderColor),

        // Nom d'utilisateur
        _buildInfoRow('Nom d\'utilisateur', user.username),
        const Divider(color: greyBorderColor),
        // Email
        _buildInfoRow('Email', user.email),
        const Divider(color: greyBorderColor),

        // Mot de passe (masqué)
        _buildInfoRow(
          'Mot de passe',
          _maskPassword(user.password),
          isPassword: true,
        ),
        const Divider(color: greyBorderColor),

        // Rôle
        _buildInfoRow('Rôle', user.role?.name ?? 'Non défini'),
      ],
    );
  }

  // Widget pour une ligne d'information
  Widget _buildInfoRow(String label, String value, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: kThirdColor,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: isPassword ? greyBorderColor : kThirdColor,
                fontSize: 16,
                fontStyle: isPassword ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
Procedure:
Supposons que nous ayons dans UserProvider une méthode pour rechercher un utilisateur par son nom d'utilisateur.

Étape 1 : Transformer StudentAccountNumber en StatelessWidget (renommé en UsernameSection pour la consultation)
Étape 2 : Réécrire ConsultBody en StatefulWidget avec un contrôleur pour le champ nom d'utilisateur.
Étape 3 : Réécrire ConsultBtn pour qu'il déclenche la recherche de l'utilisateur via le Provider.
Étape 4 : Modifier ConsultData pour qu'elle affiche les données de l'utilisateur stockées dans le Provider.

Cependant, notez que la consultation peut être faite par n'importe quel utilisateur (peut-être sans être connecté) ?
Si c'est le cas, nous n'avons pas besoin de token. Sinon, il faudra peut-être un token pour consulter.

Pour l'instant, supposons que nous voulons juste consulter un compte par le nom d'utilisateur, sans authentification.
*/

/* 
class ConsultData extends StatefulWidget {
  const ConsultData({super.key});

  @override
  State<ConsultData> createState() => _ConsultDataState();
}

class _ConsultDataState extends State<ConsultData> {
  static const String _title = 'Informations sur le compte';
  String name = "- - - - ";
  String username = "- - - - ";
  String email = "- - - - ";
  String password = "- - - - ";
  String balance = "- - - - ";

  /* Future<StudentModel> consulterCpt() async {
    var data =
        await http.get('http://localhost:8080/api/etudiants/consultAccount');
    var jsonData = jsonDecode(data.body);

    for (var etu in jsonData) {
      StudentModel etudiant;
      etudiant.solde = etu["solde"];
      etudiant.nom = etu["nom"];
      etudiant.prenom = etu["prenom"];
      etudiant.filiere = etu["filiere"];
      etudiant.tel = etu["tel"];
      etudiant. = etu["id"];
      etudiant.idCpt = etu["idCpt"];
    }
  }*/

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text(_title)),
        body: Background(
            child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 70),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  height: size.height * 0.6,
                  width: size.width * 6.0,
                  decoration: BoxDecoration(
                    color: textContainerColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                          color: boxshadowColor,
                          blurRadius: 6,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 8.0, 8.0, 8.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  StatisticsLabel(label: 'N° compte'),
                                  SizedBox(height: 5),
                                  /* Text(
                                    "- - - -",
                                    style: TextStyle(
                                        color: kThirdColor,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ), */
                                  DataConsultBack()
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  StatisticsLabel(label: 'Nom complet'),
                                  SizedBox(height: 5),
                                  DataConsultBack()
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  StatisticsLabel(label: 'Nom d\'utilisateur'),
                                  SizedBox(height: 5),
                                  DataConsultBack()
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  StatisticsLabel(label: 'Email'),
                                  SizedBox(height: 5),
                                  DataConsultBack()
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  StatisticsLabel(label: 'Mot de passe'),
                                  SizedBox(height: 5),
                                  DataConsultBack()
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  StatisticsLabel(label: 'Solde'),
                                  SizedBox(height: 5),
                                  DataConsultBack()
                                ],
                              ),
                            ],
                          ),
                          /*  FutureBuilder(
                           future: consulterCpt,
                           builder: (BuildContext context, AsyncSnapshot snapshot){
                            if (snapshot.data == null){
                              return Container(child: Center(child: Icon(Icons.error)));
                            }
                            return ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index){
                                return ListTile(
                                  title: Text(
                                    'Solde' + ' ' + ' Nom' +  ' ' + 'Prénom' + ' ' + 'N° compte' + ' '
                                  ),
                                  subtitle: 
                                  Text(
                                    '$(snapshot.data[index].solde}' +
                                    '$(snapshot.data[index].nom}' +
                                     '$(snapshot.data[index].prenom}' +
                                     '$(snapshot.data[index].numeroCompte}'
                                    )',
                                    onTap:() {
                                      
                                    },
                                    );
                                )} );
                           } ),
                           */
                        ]),
                  ),
                ),
              ]),
        )));
  }
} */
