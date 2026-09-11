// Exceptions techniques levées par la couche data.
// Elles sont interceptées dans le repository et converties en [Failure].

/// Levée quand l'API retourne 404 (ville inconnue)
class CityNotFoundException implements Exception {
  final String message;
  const CityNotFoundException([this.message = 'Ville introuvable']);

  @override
  String toString() => 'CityNotFoundException: $message';
}

/// Levée quand l'API retourne 429 (quota dépassé)
class QuotaExceededException implements Exception {
  final String message;
  const QuotaExceededException([
    this.message = 'Quota API dépassé, réessayez plus tard',
  ]);

  @override
  String toString() => 'QuotaExceededException: $message';
}

/// Levée pour toute erreur serveur 5xx
class ServerException implements Exception {
  final String message;
  final int statusCode;
  const ServerException({
    required this.statusCode,
    this.message = 'Erreur serveur',
  });

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Levée en cas d'absence de réseau ou de timeout
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Pas de connexion réseau']);

  @override
  String toString() => 'NetworkException: $message';
}
