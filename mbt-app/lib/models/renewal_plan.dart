class RenewalPlan {
  final String id;
  final String label;
  final int durationValue;
  final String durationUnit;
  final double price;
  final int sortOrder;

  RenewalPlan({
    required this.id,
    required this.label,
    required this.durationValue,
    required this.durationUnit,
    required this.price,
    required this.sortOrder,
  });

  factory RenewalPlan.fromJson(Map<String, dynamic> json) {
    return RenewalPlan(
      id: json['id'] as String,
      label: json['label'] as String,
      durationValue: (json['durationValue'] ?? 0) as int,
      durationUnit: (json['durationUnit'] ?? 'months') as String,
      price: ((json['price'] ?? 0.0) as num).toDouble(),
      sortOrder: (json['sortOrder'] ?? 0) as int,
    );
  }
}
