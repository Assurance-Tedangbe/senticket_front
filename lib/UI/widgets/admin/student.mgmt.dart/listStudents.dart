import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/admin/createAccountIcon.dart';
import 'package:senticket_front/UI/pages/updateUser.dart';
import 'package:senticket_front/UI/widgets/admin/student.mgmt.dart/dataTableStyle.dart';
import 'package:senticket_front/UI/widgets/customWidgets/customCircularProgressIndicator.dart';
import 'package:senticket_front/UI/widgets/customWidgets/headTableStyle.dart';
import 'package:senticket_front/UI/widgets/consult.account/consult.data.dart';
import 'package:senticket_front/constants.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:senticket_front/model/user_model.dart';

class ListStudentsPage extends StatefulWidget {
  const ListStudentsPage({super.key});

  @override
  State<ListStudentsPage> createState() => _ListStudentsPageState();
}

class _ListStudentsPageState extends State<ListStudentsPage> {
  @override
  void initState() {
    super.initState();
    // Charger les utilisateurs au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.loadAllUsers();
    });
  }

  // Filtrer les utilisateurs avec le rôle ETUDIANT
  List<User> _getStudents(List<User> allUsers) {
    return allUsers.where((user) {
      return user.role.name.toUpperCase() == 'ETUDIANT';
    }).toList();
  }

  Future<void> _showDeleteStudentDialog(User user) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Suppression compte Étudiant'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Êtes-vous sûr de vouloir supprimer le compte de ${user.username} ?',
                ),
                const SizedBox(height: 10),
                const Text(
                  '⚠️ Cette action est irréversible !',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ANNULER'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('SUPPRIMER'),
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );
                final success = await userProvider.deleteExistingUser(
                  user.userId!,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Compte ${user.username} supprimé avec succès',
                      ),
                      backgroundColor: validateBtnColor,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Erreur lors de la suppression: ${userProvider.error}',
                      ),
                      backgroundColor: redErrorColor,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final students = _getStudents(userProvider.users);

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // En-tête avec bouton de création
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Bouton de rafraîchissement
                    IconButton(
                      onPressed: () =>
                          userProvider.loadAllUsers(forceRefresh: true),
                      icon: const Icon(Icons.refresh, color: kPrimaryColor),
                      tooltip: 'Rafraîchir la liste',
                    ),

                    // Compteur d'étudiants
                    Text(
                      '${students.length} étudiant(s)',
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const CreateAccountIcon(),
                  ],
                ),
              ),

              // Indicateur de chargement
              if (userProvider.isLoading && students.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CustomCircularProgressIndicator(),
                  ),
                )
              else if (students.isEmpty)
                // Message si aucun étudiant
                Container(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Icon(Icons.group_off, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 20),
                      Text(
                        'Aucun étudiant trouvé',
                        style: TextStyle(color: Colors.grey[600], fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      if (userProvider.users.isNotEmpty && students.isEmpty)
                        Text(
                          'Les utilisateurs existent mais aucun n\'a le rôle ETUDIANT.',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () =>
                            userProvider.loadAllUsers(forceRefresh: true),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Rafraîchir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              else
                // Table des étudiants
                _buildStudentsTable(userProvider, students),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentsTable(UserProvider userProvider, List<User> students) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: ticketSectionColor, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: DataTable(
          sortColumnIndex: 0,
          sortAscending: true,
          showCheckboxColumn: false,
          border: TableBorder.all(width: 1.0, color: ticketSectionColor),
          columns: const [
            DataColumn(
              label: HeadTableStyle(data: "Nom d'utilisateur"),
              numeric: false,
            ),
            DataColumn(
              label: HeadTableStyle(data: "Nom complet"),
              numeric: false,
            ),
            DataColumn(label: HeadTableStyle(data: "Email"), numeric: false),
            DataColumn(label: HeadTableStyle(data: "Actions"), numeric: false),
          ],
          rows: students.map((student) {
            return DataRow(
              cells: [
                DataCell(
                  Tooltip(
                    message: 'Voir les détails',
                    child: DataTableStyle(datafromBack: student.username),
                  ),
                  onTap: () {
                    _navigateToStudentDetails(context, student);
                  },
                ),
                DataCell(
                  DataTableStyle(
                    datafromBack: '${student.firstName} ${student.lastName}',
                  ),
                ),
                DataCell(DataTableStyle(datafromBack: student.email)),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bouton Voir les détails
                      IconButton(
                        onPressed: () =>
                            _navigateToStudentDetails(context, student),
                        icon: const Icon(
                          Icons.visibility,
                          size: 30,
                          color: kPrimaryColor,
                        ),
                        tooltip: 'Voir les détails',
                      ),
                      const SizedBox(width: 4),

                      // Bouton Modifier
                      IconButton(
                        onPressed: () =>
                            _navigateToUpdateStudent(context, student),
                        icon: const Icon(
                          Icons.edit,
                          size: 30,
                          color: kPrimaryColor,
                        ),
                        tooltip: 'Modifier',
                      ),
                      const SizedBox(width: 4),

                      // Bouton Supprimer
                      IconButton(
                        onPressed: () => _showDeleteStudentDialog(student),
                        icon: const Icon(
                          Icons.delete,
                          size: 30,
                          color: kPrimaryColor,
                        ),
                        tooltip: 'Supprimer',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _navigateToStudentDetails(BuildContext context, User student) {
    // Stocker l'étudiant sélectionné dans le provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.currentUser =
        student; // Utilise le setter que nous avons ajouté

    // Naviguer vers la page de consultation
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConsultData(userId: student.userId!),
      ),
    );
  }

  void _navigateToUpdateStudent(BuildContext context, User student) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.currentUser = student;
    userProvider.prefillUpdateForm(student); // Pré-remplir le formulaire

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UpdateUser(userId: student.userId!),
      ),
    );
  }
}

/* 
refactoriser ListStudentsPage pour utiliser Provider et afficher dynamiquement la liste des étudiants.
Étapes :
- Utiliser UserProvider pour récupérer la liste des utilisateurs et filtrer ceux qui ont le rôle ETUDIANT.
- Remplacer les données statiques par des données dynamiques.
- Ajouter un FutureBuilder ou Consumer pour gérer l'état de chargement.
- Adapter les actions (voir, modifier, supprimer) pour utiliser les méthodes du provider.
Modifications :
- Remplacer StatefulWidget par StatelessWidget et utiliser Consumer pour écouter le provider.
- Ajouter une méthode dans UserProvider pour récupérer les utilisateurs par rôle (ou filtrer dans le widget).
- Gérer le chargement et les erreurs.
- créer une nouvelle méthode dans UserProvider pour charger tous les utilisateurs et ensuite filtrer par rôle ETUDIANT.
Cpdt,votre API a déjà un endpoint pr récupérer tous les utilisateurs. utiliser cette methode et ensuite filtrer.
 */
/* 
  Fonctionnalités clés de cette refactorisation :
  - Chargement dynamique : Les étudiants sont chargés depuis l'API Spring Boot
  - Filtrage par rôle : Seuls les utilisateurs avec rôle "ETUDIANT" sont affichés
  - Gestion d'état : Utilisation de Provider pour la gestion d'état centralisée
  - Actions complètes : Voir, modifier, activer/désactiver, supprimer
  - UI réactive : Indicateurs de chargement, messages d'erreur, rafraîchissement
  - Navigation : Redirection vers les pages détaillées avec données pré-remplies
  Cette architecture permet une gestion complète des étudiants avec une interface responsive 
  et des performances optimisées grâce au cache Provider.
 */

/* class ListStudentsPage extends StatefulWidget {
  // final List<Student> listStudents;
  const ListStudentsPage({
    super.key,
//   required this.listStudents
  });

  @override
  State<ListStudentsPage> createState() => _ListStudentsPageState();
}

class _ListStudentsPageState extends State<ListStudentsPage> {
  Future<void> _showDeleteStudentDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Suppression compte Etudiant'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Etes-vous sûr de vouloir supprimer ce compte'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ANNULER'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AdminInterface())),
            ),
            TextButton(
              child: const Text('OUI'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AdminInterface())),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 2.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  CreateAccountIcon(),
                ]),
          ),
          FittedBox(
            child: DataTable(
                sortColumnIndex: 1,
                showCheckboxColumn: false,
                border: TableBorder.all(width: 1.0, color: ticketSectionColor),
                columns: const [
                  DataColumn(label: HeadTableStyle(data: "Nom d'utilisateur")),
                  DataColumn(label: HeadTableStyle(data: "Email")),
                  DataColumn(label: HeadTableStyle(data: "Actions")),
                ],
                rows: [
                  // this brackets are just for test by not included in dynamic view
                  // listStudents
                  //   .map((data) =>
                  DataRow(cells: [
                    const DataCell(DataTableStyle(datafromBack: 'Tedangbe')
                        /*   Text('Tedangbe',
                          //data.username,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),*/
                        ),
                    const DataCell(
                        DataTableStyle(datafromBack: 'tedangbek@gmail.com')),
                    DataCell(Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const ConsultAccount()));
                            },
                            icon: const Icon(Icons.visibility, size: 45)),
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const UpdateUser()));
                            },
                            icon: const Icon(Icons.update, size: 45)),
                        IconButton(
                            onPressed: _showDeleteStudentDialog,
                            icon: const Icon(Icons.delete, size: 45)),
                      ],
                    )),
                  ])
                  //   )
                  //   .toList(),
                ]),
          ),
        ],
      ),
    );
  }
} */
