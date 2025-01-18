import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/daily_entity.dart';
 // تأكد من استيراد الكائن الخاص بك هنا

class DailyEntryProvider extends ChangeNotifier {
  List<DailyEntry> _dailyEntries = [];
  bool isDataLoaded = false;

  List<DailyEntry> get dailyEntries => _dailyEntries;

  // تحميل البيانات من SharedPreferences
  Future<void> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? entries = prefs.getStringList('dailyEntries');
    _dailyEntries = entries?.map((entry) => DailyEntry.fromJson(jsonDecode(entry))).toList() ?? [];
    isDataLoaded = true;
    notifyListeners();
  }

  // حفظ إدخال جديد
  Future<void> saveEntry(DailyEntry entry) async {
    _dailyEntries.add(entry);
    await _updateEntries();
    notifyListeners();
  }

  // تحديث البيانات في SharedPreferences
  Future<void> _updateEntries() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> entries = _dailyEntries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList('dailyEntries', entries);
  }

  // حذف الإدخال
  Future<void> removeEntry(DailyEntry entry) async {
    _dailyEntries.remove(entry);
    await _updateEntries();
    notifyListeners();
  }
}
