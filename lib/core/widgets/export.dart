import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/daily_entity.dart';

class DataManager {
  // دالة لتحميل المدخلات المخزنة من SharedPreferences
  Future<List<DailyEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? entries = prefs.getStringList('dailyEntries');

    return entries
        ?.map((entry) => DailyEntry.fromJson(jsonDecode(entry)))
        .toList() ?? [];
  }

  // دالة لتحديث المدخلات المخزنة في SharedPreferences
  Future<void> updateEntries(List<DailyEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> encodedEntries = entries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList('dailyEntries', encodedEntries);
  }

  // دالة لإضافة إدخال جديد إلى المدخلات المخزنة في SharedPreferences
  Future<void> saveEntry(DailyEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? entries = prefs.getStringList('dailyEntries');

    // إذا كانت المدخلات موجودة، أضف الإدخال الجديد إليها، وإذا لم تكن موجودة، قم بإنشائها
    entries = entries ?? [];
    entries.add(jsonEncode(entry.toJson()));

    await prefs.setStringList('dailyEntries', entries);
  }
}
