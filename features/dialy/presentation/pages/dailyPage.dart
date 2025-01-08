import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/widgets/add.dart'; // تعديل المسار حسب المكان الذي يحتوي على الكلاس
import '../../data/entity/daily_entity.dart'; // تأكد من أن لديك كلاس DailyEntry مع دوال toJson و fromJson

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

  @override
  void initState() {
    super.initState();
    _loadEntries();  // تحميل المدخلات عند بدء الصفحة
  }

  // دالة لتحميل المدخلات من SharedPreferences
  Future<void> _loadEntries() async {
    setState(() {
      isDataLoaded = false;
    });

    final prefs = await SharedPreferences.getInstance();
    List<String>? entries = prefs.getStringList('dailyEntries');

    setState(() {
      dailyEntries = entries?.map((entry) => DailyEntry.fromJson(jsonDecode(entry))).toList() ?? [];
      isDataLoaded = true;
    });
  }

  // دالة لحفظ المدخلات في SharedPreferences
  Future<void> _updateEntries() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> entries = dailyEntries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList('dailyEntries', entries);
  }

  // دالة لتحرير المدخل أو إضافة مدخل جديد
  Future<void> _handleEntry(DailyEntry? entry) async {
    final DailyEntry? result = await showDialog<DailyEntry>(
      context: context,
      builder: (BuildContext context) {
        return AddDailyEntryDialog(
          tableColor: widget.tableColor,
          entryToEdit: entry,
          onEntrySaved: (DailyEntry newEntry) {
            if (entry == null) {
              setState(() {
                dailyEntries.add(newEntry);
              });
            } else {
              setState(() {
                int index = dailyEntries.indexOf(entry);
                if (index != -1) {
                  dailyEntries[index] = newEntry;
                }
              });
            }
            _updateEntries(); // حفظ المدخلات بعد التعديل أو الإضافة
          },
        );
      },
    );
  }

  // دالة لحذف المدخل
  Future<void> _deleteEntry(DailyEntry entry) async {
    setState(() {
      dailyEntries.remove(entry);
    });
    _updateEntries(); // حفظ المدخلات بعد الحذف
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
                    DataColumn(label: _buildCenteredText('إجراءات')),
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
                      DataCell(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _handleEntry(entry), // تحرير المدخل
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEntry(entry), // حذف المدخل
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            )
                : Center(child: CircularProgressIndicator()), // مؤشر التحميل أثناء انتظار البيانات
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0, right: 20.0),
        child: FloatingActionButton(
          onPressed: () => _handleEntry(null), // إضافة مدخل جديد
          backgroundColor: widget.tableColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
