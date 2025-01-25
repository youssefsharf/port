import 'dart:convert';
import 'dart:ui';

class DailyEntry {
  final String name;
  final DateTime date;
  final String notes;
  final double goldForUs;

  final double goldForHim;

  final String customer; // إضافة الزبون
  final Color tableColor;

  DailyEntry({
    required this.name,
    required this.date,
    required this.notes,
    required this.goldForUs,

    required this.goldForHim,

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

      'goldForHim': goldForHim,

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

      // التأكد من أن 'syrianForUs' ليس null
      goldForHim: json['goldForHim'] ?? 0.0,
      // التأكد من أن 'goldForHim' ليس null

      // التأكد من أن 'syrianForHim' ليس null
      customer: json['customer'] ?? '',
      // التأكد من أن 'customer' ليس null
      tableColor: Color(int.parse(
          json['tableColor'] ?? '0')), // التأكد من أن 'tableColor' ليس null
    );
  }

  static List<DailyEntry> decode(String entries) =>
      (json.decode(entries) as List<dynamic>)
          .map<DailyEntry>((item) => DailyEntry.fromJson(item))
          .toList();

  static String encode(List<DailyEntry> entries) =>
      json.encode(entries.map<Map<String, dynamic>>((entry) => entry.toJson()).toList());
}





