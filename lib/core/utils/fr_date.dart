/// Formatage de dates en français, sans dépendre de l'initialisation de `intl`
/// (`initializeDateFormatting`). Suffisant pour l'affichage de l'écran principal.
class FrDate {
  FrDate._();

  static const List<String> _weekdays = [
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
    'dimanche',
  ];

  static const List<String> _months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  /// Ex. « mercredi 10 septembre ».
  static String full(DateTime date) =>
      '${_weekdays[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';

  /// Ex. « 09:05 ».
  static String time(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';

  /// Salutation contextuelle en français selon l'heure de la journée :
  /// - 05h00 - 11h59 : « Bonjour »
  /// - 12h00 - 17h59 : « Bon après-midi »
  /// - 18h00 - 04h59 : « Bonsoir »
  static String greeting(DateTime date) {
    final hour = date.hour;
    if (hour >= 5 && hour < 12) {
      return 'Bonjour';
    } else if (hour >= 12 && hour < 18) {
      return 'Bon après-midi';
    } else {
      return 'Bonsoir';
    }
  }
}
