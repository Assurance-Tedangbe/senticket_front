import 'package:flutter/material.dart';
import 'package:senticket_front/model/user_model.dart';

class UserDetailPage extends StatelessWidget {
  final User user;

  UserDetailPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'utilisateur'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigation vers la page de modification
              // Vous pouvez implémenter cette navigation si nécessaire
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec avatar et nom
            _buildUserHeader(),
            SizedBox(height: 24),

            // Informations personnelles
            _buildInfoSection(),
            SizedBox(height: 24),

            // Informations de connexion
            _buildLoginSection(),
            SizedBox(height: 24),

            // Rôle et permissions
            _buildRoleSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: _getRoleColor(user.role.name),
            child: Text(
              user.username[0].toUpperCase(),
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '${user.firstName} ${user.lastName}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '@${user.username}',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations personnelles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildInfoRow('Prénom', user.firstName),
            _buildInfoRow('Nom', user.lastName),
            _buildInfoRow('Email', user.email),
            _buildInfoRow('ID Utilisateur', user.userId?.toString() ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de connexion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildInfoRow('Nom d\'utilisateur', user.username),
            _buildInfoRow(
              'Mot de passe',
              '••••••••',
            ), // Masqué pour la sécurité
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rôle et permissions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Center(
              child: Chip(
                label: Text(
                  user.role.name,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                backgroundColor: _getRoleColor(user.role.name),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
            ),
            SizedBox(height: 12),
            _buildRoleDescription(user.role.name),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label :',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(flex: 3, child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildRoleDescription(String roleName) {
    String description = '';

    switch (roleName.toLowerCase()) {
      case 'admin':
        description =
            'Accès complet à toutes les fonctionnalités du système. Peut gérer tous les utilisateurs et paramètres.';
        break;
      case 'agent':
        description =
            'Peut gérer les étudiants et les portiers. Accès limité aux fonctionnalités administratives.';
        break;
      case 'etudiant':
        description =
            'Accès aux fonctionnalités étudiantes. Peut consulter son profil et ses informations personnelles.';
        break;
      case 'portier':
        description =
            'Accès aux fonctionnalités de contrôle d\'accès. Peut gérer les entrées et sorties.';
        break;
      default:
        description = 'Rôle personnalisé avec des permissions spécifiques.';
    }

    return Text(
      description,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
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
}
