import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/widgets/add.dart';
import '../../data/entity/daily_entity.dart'; // تعديل المسار حسب المكان الذي يحتوي على الكلاس

class DailyPage extends StatefulWidget {
  final String title;
  final Color tableColor;

  const DailyPage({
    super.key,
    required this.title,
    required this.tableColor,
  });

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  List<DailyEntry> dailyEntries = [];
  bool isDataLoaded = false;

  // دالة لتحميل المدخلات من SharedPreferences
  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? entries = prefs.getStringList('dailyEntries');

    if (entries != null) {
      setState(() {
        dailyEntries = entries.map((entry) {
          final Map<String, dynamic> data = jsonDecode(entry);
          return DailyEntry.fromJson(data);  // تأكد من أن لديك دالة fromJson في كلاس DailyEntry
        }).toList();
        isDataLoaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadEntries();  // تحميل المدخلات عند بدء الصفحة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.tableColor,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // عرض الجدول باستخدام DataTable
            isDataLoaded
                ? Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  horizontalMargin: 12,
                  headingRowHeight: 60,
                  dataRowHeight: 60,
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
                  headingRowColor: MaterialStateProperty.all(widget.tableColor),
                  columns: [
                    DataColumn(label: _buildCenteredText('الاسم')),
                    DataColumn(label: _buildCenteredText('التاريخ')),
                    DataColumn(label: _buildCenteredText('البيان')),
                    DataColumn(label: _buildCenteredText('ذهب لنا')),
                    DataColumn(label: _buildCenteredText('سوري لنا')),
                    DataColumn(label: _buildCenteredText('ذهب له')),
                    DataColumn(label: _buildCenteredText('سوري له')),
                  ],
                  rows: dailyEntries.map((entry) {
                    return DataRow(cells: [
                      DataCell(_buildCenteredText(entry.name)),
                      DataCell(_buildCenteredText(DateFormat('yyyy-MM-dd').format(entry.date))),
                      DataCell(_buildCenteredText(entry.notes)),
                      DataCell(_buildCenteredText(entry.goldForUs.toString())),
                      DataCell(_buildCenteredText(entry.syrianForUs.toString())),
                      DataCell(_buildCenteredText(entry.goldForHim.toString())),
                      DataCell(_buildCenteredText(entry.syrianForHim.toString())),
                    ]);
                  }).toList(),
                ),
              ),
            )
                : Center(
              child: Text('لا توجد مدخلات حالياً'),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0, right: 20.0),
        child: FloatingActionButton(
          onPressed: () async {
            final DailyEntry? newEntry = await showDialog<DailyEntry>(
              context: context,
              builder: (BuildContext context) {
                return AddDailyEntryDialog(
                  tableColor: widget.tableColor,
                  onEntrySaved: (DailyEntry entry) {
                    setState(() {
                      dailyEntries.add(entry);
                      isDataLoaded = true;
                    });
                    _saveEntry(entry);  // حفظ المدخل في SharedPreferences
                  },
                );
              },
            );
          },
          backgroundColor: widget.tableColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // دالة لحفظ المدخل الجديد في SharedPreferences
  Future<void> _saveEntry(DailyEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> entries = prefs.getStringList('dailyEntries') ?? [];

    // تحويل الكائن إلى JSON ثم إضافته إلى القائمة
    String entryJson = jsonEncode(entry.toJson());  // تأكد من أن لديك دالة toJson في كلاس DailyEntry
    entries.add(entryJson);

    // حفظ المدخلات مرة أخرى
    await prefs.setStringList('dailyEntries', entries);
  }

  // دالة لبناء النصوص مع المحاذاة المركزية
  Widget _buildCenteredText(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}
