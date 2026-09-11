import 'package:flutter/material.dart';

/// Champ de recherche de ville de l'écran principal, style « verre dépoli »
/// posé sur le dégradé de fond.
///
/// Périmètre F05/F06 : simple saisie + validation.
/// TODO(Recherche & Favoris - F07/F08): brancher ici l'autocomplétion,
/// l'historique des recherches et le bouton « ajouter aux favoris ».
class CitySearchField extends StatefulWidget {
  const CitySearchField({
    super.key,
    required this.onSubmitted,
    this.onUseLocation,
  });

  /// Appelé avec le nom de ville validé (jamais vide).
  final ValueChanged<String> onSubmitted;

  /// Appelé quand l'utilisateur demande la météo de sa position (F04).
  final VoidCallback? onUseLocation;

  @override
  State<CitySearchField> createState() => _CitySearchFieldState();
}

class _CitySearchFieldState extends State<CitySearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    FocusScope.of(context).unfocus();
    widget.onSubmitted(value);
  }

  @override
  Widget build(BuildContext context) {
    final hintColor = Colors.white.withValues(alpha: 0.70);
    final iconColor = Colors.white.withValues(alpha: 0.90);

    OutlineInputBorder border(double alpha) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: alpha == 0
          ? BorderSide.none
          : BorderSide(color: Colors.white.withValues(alpha: alpha)),
    );

    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _submit(),
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.16),
        hintText: 'Rechercher une ville…',
        hintStyle: TextStyle(color: hintColor),
        prefixIcon: Icon(Icons.search_rounded, color: iconColor),
        suffixIcon: widget.onUseLocation == null
            ? null
            : IconButton(
                tooltip: 'Ma position',
                icon: Icon(Icons.my_location_rounded, color: iconColor),
                onPressed: widget.onUseLocation,
              ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: border(0),
        enabledBorder: border(0),
        focusedBorder: border(0.5),
      ),
    );
  }
}
