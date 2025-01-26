import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../data/models/daily_entity.dart';

class CustomerInfoPage extends StatefulWidget {
  final String title;
  final Color tableColor;
  final List<DailyEntry> customerEntries;

  const CustomerInfoPage({
    super.key,
    required this.title,
    required this.tableColor,
    required this.customerEntries,
  });

  @override
  _CustomerInfoPageState createState() => _CustomerInfoPageState();
}

class _CustomerInfoPageState extends State<CustomerInfoPage> {
  List<DailyEntry> debtsEntries = [];
  List<DailyEntry> filteredEntries = [];

  @override
  void initState() {
    super.initState();
    _loadDebtsEntries();
  }

  Future<void> _loadDebtsEntries() async {
    final prefs = await SharedPreferences.getInstance();

    // تحميل البيانات المخزنة مسبقاً
    List<String>? storedEntries = prefs.getStringList('debtsEntries');

    if (storedEntries != null) {
      // فك ترميز البيانات المحفوظة وتحويلها إلى كائنات DailyEntry
      List<DailyEntry> oldEntries = storedEntries
          .map((entry) => DailyEntry.fromJson(jsonDecode(entry)))
          .toList();

      // دمج البيانات القديمة مع البيانات الجديدة
      setState(() {
        debtsEntries = oldEntries + widget.customerEntries;
        filteredEntries = debtsEntries; // في البداية جميع الإدخالات معروضة
      });
    } else {
      // إذا لم تكن هناك بيانات محفوظة، استخدم البيانات الجديدة فقط
      setState(() {
        debtsEntries = widget.customerEntries;
        filteredEntries = debtsEntries; // في البداية جميع الإدخالات معروضة
      });
    }

    // حفظ البيانات الجديدة
    _saveDebtsEntries();
  }

  Future<void> _saveDebtsEntries() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> entries =
    debtsEntries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList('debtsEntries', entries); // حفظ جميع البيانات
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.tableColor,
      ),
      body: ListView.builder(
        itemCount: filteredEntries.length,
        itemBuilder: (context, index) {
          final entry = filteredEntries[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("الاسم: ${entry.name}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                 // Text("التاريخ: ${DateFormat('yyyy-MM-dd').format(entry.date)}"),
                  //Text("البيان: ${entry.notes}"),
                  //Text("ذهب لنا: ${entry.goldForUs}"),
                  //Text("ذهب له: ${entry.goldForHim}"),
                  Text("معلومات الزبون: ${entry.customerInfo}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}