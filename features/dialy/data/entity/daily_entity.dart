import 'dart:ui';

class DailyEntry {
  final String name;
  final DateTime date;
  final String notes;
  final double goldForUs;
  final double syrianForUs;
  final double goldForHim;
  final double syrianForHim;
  final Color tableColor;

  DailyEntry({
    required this.name,
    required this.date,
    required this.notes,
    required this.goldForUs,
    required this.syrianForUs,
    required this.goldForHim,
    required this.syrianForHim,
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
      'tableColor': tableColor.value.toString(),  // تحويل اللون إلى قيمة رقمية
    };
  }

  // تحويل JSON إلى الكائن
  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      name: json['name'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      goldForUs: json['goldForUs'],
      syrianForUs: json['syrianForUs'],
      goldForHim: json['goldForHim'],
      syrianForHim: json['syrianForHim'],
      tableColor: Color(int.parse(json['tableColor'])),
    );
  }
}
