class DurationFormatter {
  static String format(String? raw) {
    if (raw == null || raw.isEmpty) return 'Self paced';
    if (raw.contains(':')) return raw;
    final num = double.tryParse(raw);
    if (num == null || num <= 0) return raw;
    if (num >= 60) {
      final total = num.round();
      final h = total ~/ 3600;
      final m = (total % 3600) ~/ 60;
      final s = total % 60;
      if (h > 0) {
        return '${h}h ${m}m';
      }
      return '${m}m ${s}s';
    }
    return raw;
  }

  static String formatHours(String? raw) {
    if (raw == null || raw.isEmpty) return 'Self paced';
    final num = double.tryParse(raw);
    if (num == null || num <= 0) return raw;
    if (num >= 60) {
      final total = num.round();
      final h = total ~/ 3600;
      final m = (total % 3600) ~/ 60;
      if (h > 0) {
        return '${h}h ${m}m';
      }
      return '${m}m';
    }
    return '${num.round()}hours';
  }
}
