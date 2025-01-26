import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/daily_entity.dart';

class DebtsPage extends StatefulWidget {
  final String title;
  final Color tableColor;
  final List<DailyEntry> initialEntries;

  const DebtsPage({
    super.key,
    required this.title,
    required this.tableColor,
    required this.initialEntries,
  });

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> {
  List<DailyEntry> debtsEntries = [];
  List<DailyEntry> filteredEntries = [];
  String? selectedName; // الاسم المختار من القائمة المنسدلة

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
        debtsEntries = oldEntries + widget.initialEntries;
        filteredEntries = debtsEntries; // في البداية جميع الإدخالات معروضة
      });
    } else {
      // إذا لم تكن هناك بيانات محفوظة، استخدم البيانات الجديدة فقط
      setState(() {
        debtsEntries = widget.initialEntries;
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

  // دوال لحساب المجموع
  double get totalGoldForUs => filteredEntries.fold(0, (sum, entry) => sum + entry.goldForUs);
  double get totalGoldForHim => filteredEntries.fold(0, (sum, entry) => sum + entry.goldForHim);

  // فلترة الإدخالات بناءً على الاسم المختار
  void _filterEntries(String? selectedName) {
    setState(() {
      if (selectedName == null || selectedName.isEmpty) {
        filteredEntries = debtsEntries; // عرض جميع الإدخالات إذا لم يتم اختيار أي اسم
      } else {
        filteredEntries = debtsEntries
            .where((entry) => entry.name == selectedName) // الفلترة حسب الاسم المختار
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // قائمة الأسماء الفريدة للاختيار منها
    List<String> uniqueNames = debtsEntries.map((entry) => entry.name).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 98.0),
          child: Text(widget.title),
        ),
        backgroundColor: widget.tableColor,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // إضافة DropdownButton لاختيار الاسم
              DropdownButton<String>(
                hint: Text("اختر الاسم للفلترة"),
                value: selectedName,
                items: uniqueNames.map((name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedName = value;
                  });
                  _filterEntries(value); // استدعاء دالة الفلترة عند تغيير الاختيار
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 22,
                    horizontalMargin: 10,
                    headingRowHeight: 60,
                    dataRowHeight: 70,
                    headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    border: TableBorder.all(
                      color: Colors.grey.shade400,
                      width: 1,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    headingRowColor:
                    MaterialStateProperty.all(widget.tableColor),
                    columns: [
                      DataColumn(label: _buildCenteredText('الاسم', width: 150)),
                      DataColumn(
                          label: _buildCenteredText('التاريخ', width: 100)),
                      DataColumn(
                          label: _buildCenteredText('البيان', width: 150)),
                      DataColumn(label: _buildCenteredText('ذهب لنا')),
                      DataColumn(label: _buildCenteredText('ذهب له')),
                      DataColumn(label: _buildCenteredText('الزبون')),
                    ],
                    rows: filteredEntries.map((entry) {
                      return DataRow(cells: [
                        DataCell(_buildCenteredText(entry.name)),
                        DataCell(_buildCenteredText(
                            DateFormat('yyyy-MM-dd').format(entry.date))),
                        DataCell(_buildCenteredText(entry.notes)),
                        DataCell(
                            _buildCenteredText(entry.goldForUs.toString())),
                        DataCell(
                            _buildCenteredText(entry.goldForHim.toString())),
                        DataCell(_buildCenteredText(entry.customer)),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              // إضافة المجموع أسفل الجدول باستخدام Padding
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "مجموع ذهب لنا: ${totalGoldForUs.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 20),
                      Text(
                        "مجموع ذهب له: ${totalGoldForHim.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredText(String text, {double width = 120}) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}