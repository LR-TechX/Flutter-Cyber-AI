class Normalizer {
  static String normalizeQuestion(String input) {
    final lower = input.toLowerCase().trim();
    final stripped = lower.replaceAll(RegExp(r"[\p{P}\p{S}]", unicode: true), ' ');
    return stripped.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
