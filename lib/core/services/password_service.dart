import 'dart:math';

class PasswordScore {
  final int score; // 0-100
  final double entropyBits;
  final List<String> suggestions;
  const PasswordScore(this.score, this.entropyBits, this.suggestions);
}

class PasswordService {
  PasswordScore evaluate(String password) {
    if (password.isEmpty) {
      return const PasswordScore(0, 0, ['Enter a password to evaluate.']);
    }

    int length = password.length;
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSymbol = password.contains(RegExp(r'[^A-Za-z0-9]'));
    bool repeated = RegExp(r'(.)\1{2,}').hasMatch(password);
    bool sequential = RegExp(r'0123|1234|2345|3456|4567|5678|6789|abcd|bcde|cdef|qwer|asdf', caseSensitive: false).hasMatch(password);
    bool common = _isCommon(password);

    int variety = [hasLower, hasUpper, hasDigit, hasSymbol].where((b) => b).length;
    double charset = 0;
    if (hasLower) charset += 26;
    if (hasUpper) charset += 26;
    if (hasDigit) charset += 10;
    if (hasSymbol) charset += 33; // rough
    double entropy = length * (charset == 0 ? 0 : (log(charset) / log(2)));

    int score = (entropy.clamp(0, 128) / 128.0 * 100).round();
    // penalties
    if (length < 8) score -= 25;
    if (variety <= 1) score -= 15;
    if (repeated) score -= 10;
    if (sequential) score -= 10;
    if (common) score = min(score, 20);
    score = score.clamp(0, 100);

    final suggestions = <String>[];
    if (length < 12) suggestions.add('Use at least 12 characters.');
    if (variety < 3) suggestions.add('Mix upper/lowercase, digits, and symbols.');
    if (repeated) suggestions.add('Avoid repeated characters or patterns.');
    if (sequential) suggestions.add('Avoid sequences like 1234 or abcd.');
    if (common) suggestions.add('Avoid common passwords or dictionary words.');
    if (suggestions.isEmpty) suggestions.add('Great! Consider a passphrase for even more security.');

    return PasswordScore(score, entropy, suggestions);
  }

  bool _isCommon(String p) {
    final lower = p.toLowerCase();
    const commonList = [
      'password','123456','qwerty','letmein','admin','welcome','iloveyou','abc123','111111','dragon','monkey','football','sunshine','princess','trustno1','qwertyuiop','passw0rd','baseball','starwars','login'
    ];
    if (commonList.contains(lower)) return true;
    if (RegExp(r'^(?:[a-z]{4,}|[0-9]{6,})$').hasMatch(lower)) return true;
    return false;
  }
}
