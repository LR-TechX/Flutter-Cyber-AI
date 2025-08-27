class PhishingResult {
  final bool risky;
  final List<String> reasons;
  const PhishingResult(this.risky, this.reasons);
}

class PhishingService {
  PhishingResult check(String url) {
    final reasons = <String>[];
    final trimmed = url.trim();
    final lower = trimmed.toLowerCase();
    final httpOnly = lower.startsWith('http://');
    final hasIp = RegExp(r'^https?://\d+\.\d+\.\d+\.\d+').hasMatch(lower);
    final manySubs = RegExp(r'^https?://([^.]+\.){3,}').hasMatch(lower);
    final badTld = RegExp(r'\.(zip|mov|xyz|top|ru|cn|tk)(/|$)').hasMatch(lower);
    final tracking = lower.contains('utm_') || lower.contains('ref=');
    final looksLike = RegExp(r'(paypa1|rnicrosoft|faceb00k|go0gle|appleid|micr0soft)').hasMatch(lower);

    if (httpOnly) reasons.add('Uses HTTP, not HTTPS.');
    if (hasIp) reasons.add('Uses raw IP address instead of domain.');
    if (manySubs) reasons.add('Excessive subdomains may hide real domain.');
    if (badTld) reasons.add('Suspicious or high-abuse TLD.');
    if (tracking) reasons.add('Contains tracking parameters.');
    if (looksLike) reasons.add('Look-alike domain patterns detected.');

    return PhishingResult(reasons.isNotEmpty, reasons);
  }
}
