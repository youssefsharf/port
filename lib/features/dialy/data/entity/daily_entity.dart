import 'dart:ui';

import 'package:flutter/material.dart';

class DailyEntry {
  final String name;
  final String notes;
  final double goldForUs;
  final double syrianForUs;
  final double goldForHim;
  final double syrianForHim;
  final DateTime date;
  //final String customerType; // إضافة حقل نوع الزبون
  final Color tableColor;

  DailyEntry({
    required this.name,
    required this.notes,
    required this.goldForUs,
    required this.syrianForUs,
    required this.goldForHim,
    required this.syrianForHim,
    required this.date,
    //required this.customerType, // تأكد من إضافته هنا
    required this.tableColor,
  });

  // دوال toJson و fromJson يجب أن تتعامل مع customerType أيضاً.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'notes': notes,
      'goldForUs': goldForUs,
      'syrianForUs': syrianForUs,
      'goldForHim': goldForHim,
      'syrianForHim': syrianForHim,
      'date': date.toIso8601String(),
      //'customerType': customerType, // حفظ نوع الزبون
    };
  }

  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      name: json['name'],
      notes: json['notes'],
      goldForUs: json['goldForUs'],
      syrianForUs: json['syrianForUs'],
      goldForHim: json['goldForHim'],
      syrianForHim: json['syrianForHim'],
      date: DateTime.parse(json['date']),
      //customerType: json['customerType'], // تحميل نوع الزبون
      tableColor: Colors.white, // يمكن تعديلها حسب الحاجة
    );
  }
}
