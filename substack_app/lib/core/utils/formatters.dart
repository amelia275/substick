// Dari screenshot hanya "mg" (minggu) yang pasti. Satuan lain adalah tebakan.
String formatPostTime(DateTime? date) {
  if (date == null) return '';

  final difference = DateTime.now().difference(date.toLocal());

  if (difference.inMinutes < 1) return 'Baru saja';
  if (difference.inHours < 1) return '${difference.inMinutes}m';
  if (difference.inDays < 1) return '${difference.inHours}j';
  if (difference.inDays < 7) return '${difference.inDays}h';
  if (difference.inDays < 30) return '${difference.inDays ~/ 7}mg';
  if (difference.inDays < 365) return '${difference.inDays ~/ 30}bln';
  return '${difference.inDays ~/ 365}th';
}

String formatCount(int value) {
  if (value < 1000) return '$value';
  if (value >= 10000) return '${value ~/ 1000}k';

  final tenths = value ~/ 100; // 6350 -> 63
  final whole = tenths ~/ 10;
  final fraction = tenths % 10;
  return fraction == 0 ? '${whole}k' : '$whole,${fraction}k';
}