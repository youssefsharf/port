import 'dart:ui';

class DailyEntry {
  final String name;
  final DateTime date;
  final String notes;
  final double goldForUs;
  final double syrianForUs;
  final double goldForHim;
  final double syrianForHim;
  final String customer; // إضافة الزبون
  final Color tableColor;

  DailyEntry({
    required this.name,
    required this.date,
    required this.notes,
    required this.goldForUs,
    required this.syrianForUs,
    required this.goldForHim,
    required this.syrianForHim,
    required this.customer, // إضافة الزبون
    required this.tableColor,
  });

  // تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'notes': notes,
      'goldForUs': goldForUs,
      'syrianForUs': syrianForUs,
      'goldForHim': goldForHim,
      'syrianForHim': syrianForHim,
      'customer': customer, // إضافة الزبون في JSON
      'tableColor': tableColor.value.toString(), // تحويل اللون إلى قيمة رقمية
    };
  }

  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      name: json['name'] ?? '',
      // التأكد من أن 'name' ليس null
      date: DateTime.parse(json['date']),
      notes: json['notes'] ?? '',
      // التأكد من أن 'notes' ليس null
      goldForUs: json['goldForUs'] ?? 0.0,
      // التأكد من أن 'goldForUs' ليس null
      syrianForUs: json['syrianForUs'] ?? 0.0,
      // التأكد من أن 'syrianForUs' ليس null
      goldForHim: json['goldForHim'] ?? 0.0,
      // التأكد من أن 'goldForHim' ليس null
      syrianForHim: json['syrianForHim'] ?? 0.0,
      // التأكد من أن 'syrianForHim' ليس null
      customer: json['customer'] ?? '',
      // التأكد من أن 'customer' ليس null
      tableColor: Color(int.parse(
          json['tableColor'] ?? '0')), // التأكد من أن 'tableColor' ليس null
    );
  }
}