import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/updateUser.dart';
import 'package:senticket_front/UI/widgets/admin/createAccountIcon.dart';
import 'package:senticket_front/UI/widgets/admin/student.mgmt.dart/dataTableStyle.dart';
import 'package:senticket_front/UI/widgets/admin/student.mgmt.dart/headTableStyle.dart';
import 'package:senticket_front/UI/widgets/consult.account/consult.data.dart';
import 'package:senticket_front/constants.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:senticket_front/model/user_model.dart';

class ListAgentsPage extends StatefulWidget {
  const ListAgentsPage({super.key});

  @override
  State<ListAgentsPage> createState() => _ListAgentsPageState();
}

class _ListAgentsPageState extends State<ListAgentsPage> {
  @override
  void initState() {
    super.initState();
    // Charger les utilisateurs au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.loadAllUsers();
    });
  }

  // Filtrer les utilisateurs avec le rôle AGENT
  List<User> _getAgents(List<User> allUsers) {
    return allUsers.where((user) {
      return user.role?.name?.toUpperCase() == 'AGENT';
    }).toList();
  }

  Future<void> _showDeleteAgentDialog(User agent) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Suppression compte Agent'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Êtes-vous sûr de vouloir supprimer le compte de ${agent.username} ?',
                  style: const TextStyle(fontSize: 16),
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
              child: const Text(
                'SUPPRIMER',
                style: TextStyle(color: kPrimaryColor),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAgent(agent);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAgent(User agent) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.deleteExistingUser(agent.userId!);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Compte ${agent.username} supprimé avec succès'),
          backgroundColor: validateBtnColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: ${userProvider.error}'),
          backgroundColor: redErrorColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _navigateToAgentDetails(BuildContext context, User agent) {
    // Stocker l'éagent sélectionné dans le provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.currentUser = agent; // Utilise le setter que nous avons ajouté

    // Naviguer vers la page de consultation
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConsultData(userId: agent.userId!),
      ),
    );
  }

  void _navigateToUpdateAgent(BuildContext context, User agent) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.currentUser = agent;
    userProvider.prefillUpdateForm(agent); // Pré-remplir le formulaire

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const UpdateUser()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final agents = _getAgents(userProvider.users);

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // En-tête avec bouton de création et compteur
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

                    // Compteur d'agents
                    Text(
                      '${agents.length} agent(s)',
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
              if (userProvider.isLoading && agents.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  ),
                )
              else if (agents.isEmpty)
                // Message si aucun agent
                Container(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Icon(Icons.group_off, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 20),
                      const Text(
                        'Aucun agent trouvé',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (userProvider.users.isNotEmpty && agents.isEmpty)
                        const Text(
                          'Les utilisateurs existent mais aucun n\'a le rôle AGENT.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
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
                // Table des agents
                _buildAgentsTable(agents),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAgentsTable(List<User> agents) {
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
          /* headingRowHeight: 50,
          dataRowHeight: 60,
          horizontalMargin: 16,
          columnSpacing: 24, */
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
          rows: agents.map((agent) {
            return DataRow(
              cells: [
                DataCell(
                  Tooltip(
                    message: 'Voir les détails',
                    child: DataTableStyle(datafromBack: agent.username),
                  ),
                  onTap: () => _navigateToAgentDetails(context, agent),
                ),
                DataCell(
                  DataTableStyle(
                    datafromBack: '${agent.firstName} ${agent.lastName}',
                  ),
                ),
                DataCell(DataTableStyle(datafromBack: agent.email)),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bouton Voir les détails
                      Tooltip(
                        message: 'Voir les détails',
                        child: IconButton(
                          onPressed: () =>
                              _navigateToAgentDetails(context, agent),
                          icon: const Icon(
                            Icons.visibility,
                            size: 30,
                            color: kPrimaryColor,
                          ),
                          padding: const EdgeInsets.all(6),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Bouton Modifier
                      Tooltip(
                        message: 'Modifier',
                        child: IconButton(
                          onPressed: () =>
                              _navigateToUpdateAgent(context, agent),
                          icon: const Icon(
                            Icons.edit,
                            size: 30,
                            color: kPrimaryColor,
                          ),
                          padding: const EdgeInsets.all(6),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Bouton Supprimer
                      Tooltip(
                        message: 'Supprimer',
                        child: IconButton(
                          onPressed: () => _showDeleteAgentDialog(agent),
                          icon: const Icon(
                            Icons.delete,
                            size: 30,
                            color: kPrimaryColor,
                          ),
                          padding: const EdgeInsets.all(6),
                        ),
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
}
