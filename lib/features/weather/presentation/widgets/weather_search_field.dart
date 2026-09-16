import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'glass_container.dart';

/// Barre de recherche météo élégante en forme de pilule (Fonctionnalité 4).
///
/// Caractéristiques :
/// - Forme de pilule avec style glassmorphism
/// - Icône de recherche
/// - Validation sur la touche Entrée et via bouton d'action
/// - Bouton pour vider le texte (clear)
/// - Indicateur de chargement [isLoading]
/// - Support de géolocalisation [onUseLocation]
/// - Gestion d'erreur visuelle [errorMessage]
/// - Évite les requêtes vides
class WeatherSearchField extends StatefulWidget {
  const WeatherSearchField({
    super.key,
    required this.onSubmitted,
    this.onUseLocation,
    this.isLoading = false,
    this.errorMessage,
    this.initialValue,
  });

  final ValueChanged<String> onSubmitted;
  final VoidCallback? onUseLocation;
  final bool isLoading;
  final String? errorMessage;
  final String? initialValue;

  @override
  State<WeatherSearchField> createState() => _WeatherSearchFieldState();
}

class _WeatherSearchFieldState extends State<WeatherSearchField> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final query = _controller.text.trim();
    if (query.isEmpty || widget.isLoading) return;
    FocusScope.of(context).unfocus();
    widget.onSubmitted(query);
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _hasText = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hintColor = Colors.white.withValues(alpha: 0.65);
    final iconColor = Colors.white.withValues(alpha: 0.90);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          borderRadius: BorderRadius.circular(32),
          backgroundColor: GlassStyles.searchFieldBackground(context),
          borderColor: widget.errorMessage != null
              ? Colors.redAccent.withValues(alpha: 0.6)
              : isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.25),
          borderWidth: widget.errorMessage != null ? 1.5 : 1.0,
          child: Row(
            children: [
              // Icône loupe
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 8),
                child: Icon(Icons.search_rounded, color: iconColor, size: 22),
              ),

              // Champ texte
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submit(),
                  cursorColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Rechercher une ville…',
                    hintStyle: TextStyle(color: hintColor, fontSize: 15),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              // Bouton pour vider le texte
              if (_hasText && !widget.isLoading)
                IconButton(
                  tooltip: 'Effacer',
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: Colors.white70,
                  splashRadius: 18,
                  onPressed: _clear,
                ),

              // Spinner de chargement
              if (widget.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Bouton valider / recherche
              if (_hasText && !widget.isLoading)
                IconButton(
                  tooltip: 'Lancer la recherche',
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  color: Colors.white,
                  splashRadius: 20,
                  onPressed: _submit,
                ),

              // Bouton Géolocalisation
              if (widget.onUseLocation != null && !widget.isLoading)
                IconButton(
                  tooltip: 'Ma position',
                  icon: const Icon(Icons.my_location_rounded, size: 20),
                  color: iconColor,
                  splashRadius: 20,
                  onPressed: widget.onUseLocation,
                ),
            ],
          ),
        ),

        // Message d'erreur éventuel
        if (widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 16, right: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: Color(0xFFFFB4AB),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFFFB4AB),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
