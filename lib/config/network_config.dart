// Fichier: lib/config/network_config.dart
import 'dart:io'; // Pour Platform.isAndroid, Platform.isIOS
import 'package:flutter/foundation.dart'; // Pour kIsWeb

/*
 * CLASSE DE CONFIGURATION RÉSEAU
 * Cette classe centralise toutes les configurations liées au réseau.
 * Elle retourne l'URL correcte selon la plateforme d'exécution.
 */
class NetworkConfig {
  static const String _pcLocalIp = '192.168.1.2';

  /// ============ SECTION 1: URL DE BASE PAR PLATEFORME ============
  /// Retourne l'URL de base de l'API selon la plateforme d'exécution
  static String get baseUrl {
    // Cas 1: Application web (depuis un navigateur)
    if (kIsWeb) {
      print('🌐 Plateforme: Web');
      return 'http://localhost:8080'; // Web accède directement au localhost
    }
    // Cas 2: Application Android (émulateur ou appareil réel)
    else if (Platform.isAndroid) {
      print('Plateforme: Android');
      // ADRESSE CRITIQUE: L'émulateur Android utilise 192.168.1.4 pour l'hôte
      return 'http://$_pcLocalIp:8080';
    }
    // Cas 3: Application iOS (simulateur ou appareil réel)
    else if (Platform.isIOS) {
      print('Plateforme: iOS');
      // Le simulateur iOS partage le réseau avec l'hôte
      return 'http://localhost:8080';
    }
    // Cas 4: Desktop (Windows, macOS, Linux) ou autre
    else {
      print('Plateforme: Desktop/autre - Utilisation de localhost');
      return 'http://localhost:8080';
    }
  }

  /// ============ SECTION 2: CONFIGURATION ENVIRONNEMENT ============
  /// Gère les URLs selon l'environnement (dev, staging, prod)
  static String get apiBaseUrl {
    // Vous pouvez utiliser des variables de compilation pour différents environnements
    const String env = String.fromEnvironment('ENV', defaultValue: 'dev');

    print('🎯 Environnement détecté: $env');

    if (env == 'prod') {
      // Production: URL HTTPS avec domaine réel
      return 'https://api.votre-restaurant.com';
    } else if (env == 'staging') {
      // Staging: URL de test
      return 'https://staging-api.votre-restaurant.com';
    } else {
      // Développement: URL locale
      return baseUrl;
    }
  }

  /// ============ SECTION 3: EN-TÊTES PAR DÉFAUT ============
  /// Headers HTTP communs à toutes les requêtes
  static Map<String, String> get defaultHeaders {
    return {
      'Content-Type': 'application/json', // Nous envoyons du JSON
      'Accept': 'application/json', // Nous attendons du JSON en retour
      'Connection': 'keep-alive', // Maintenir la connexion ouverte
    };
  }

  /// ============ SECTION 4: CONFIGURATION DES TIMEOUTS ============
  /// Durées maximales d'attente pour les requêtes réseau
  static Duration get connectTimeout => const Duration(seconds: 30);
  static Duration get receiveTimeout => const Duration(seconds: 30);
  static Duration get sendTimeout => const Duration(seconds: 30);

  /// ============ SECTION 5: UTILITAIRES ============
  /// Affiche la configuration réseau actuelle (utile pour le débogage)
  static void printConfig() {
    print('''
    ============ CONFIGURATION RÉSEAU ============
    URL de base: $baseUrl
    URL API: $apiBaseUrl
    Plateforme: ${kIsWeb ? 'Web' : Platform.operatingSystem}
    Headers par défaut: $defaultHeaders
    =============================================
    ''');
  }
}
