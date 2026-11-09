import 'package:senticket_front/core/utils/error_handler.dart';

/// Exception dont le message est déjà lisible par l'utilisateur.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  /// Convertit n'importe quelle erreur en ApiException (sans double emballage)
  factory ApiException.from(Object e) =>
      e is ApiException ? e : ApiException(ErrorHandler.fromException(e));

  @override
  String toString() => message;
}