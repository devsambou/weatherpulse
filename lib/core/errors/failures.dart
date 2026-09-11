import 'package:equatable/equatable.dart';

/// Représente les erreurs métier, indépendantes de l'implémentation (API, cache, GPS...)
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// F03 — Ville introuvable (HTTP 404)
class CityNotFoundFailure extends Failure {
  const CityNotFoundFailure(super.message);
}

/// F03 — Quota API dépassé (HTTP 429)
class QuotaExceededFailure extends Failure {
  const QuotaExceededFailure(super.message);
}

/// F03 — Erreur serveur (HTTP 5xx)
class ServerErrorFailure extends Failure {
  final int statusCode;
  const ServerErrorFailure(super.message, {required this.statusCode});

  @override
  List<Object> get props => [message, statusCode];
}
