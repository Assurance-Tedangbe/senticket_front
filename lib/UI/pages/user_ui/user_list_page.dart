import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/user_ui/user_detail_page.dart';
import 'package:senticket_front/UI/pages/user_ui/user_form_page.dart';
import 'package:senticket_front/model/user_model.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';

// Main screen displaying the list of users
class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Utilisateurs'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => context.read<UserProvider>().loadAllUsers(),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToUserForm(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading && userProvider.users.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (userProvider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 64),
                SizedBox(height: 16),
                Text(
                  'Erreur',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    userProvider.error,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => userProvider.loadAllUsers(),
                  child: Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (userProvider.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Aucun utilisateur',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: userProvider.users.length,
          itemBuilder: (context, index) {
            final user = userProvider.users[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(user.username[0].toUpperCase()),
                ),
                title: Text('${user.firstName} ${user.lastName}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('@${user.username}'),
                    Text(user.email),
                    Chip(
                      label: Text(
                        user.role.name,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: _getRoleColor(user.role.name),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) =>
                      _handleMenuAction(context, value, user),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(value: 'view', child: Text('Voir détails')),
                    PopupMenuItem(value: 'edit', child: Text('Modifier')),
                    PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                  ],
                ),
                onTap: () => _navigateToUserDetail(context, user),
              ),
            );
          },
        );
      },
    );
  }

  Color _getRoleColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'agent':
        return Colors.blue;
      case 'etudiant':
        return Colors.green;
      case 'portier':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _handleMenuAction(BuildContext context, String action, User user) {
    switch (action) {
      case 'view':
        _navigateToUserDetail(context, user);
        break;
      case 'edit':
        _navigateToUserForm(context, user);
        break;
      case 'delete':
        _deleteUser(context, user.userId!);
        break;
    }
  }

  void _navigateToUserForm(BuildContext context, [User? user]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserFormPage(user: user)),
    );
  }

  void _navigateToUserDetail(BuildContext context, User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailPage(user: user)),
    );
  }

  Future<void> _deleteUser(BuildContext context, int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer cet utilisateur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<UserProvider>().deleteExistingUser(
        userId,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur supprimé avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
