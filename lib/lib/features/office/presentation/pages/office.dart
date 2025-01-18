


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/daily_entity.dart';

class OfficePage extends StatefulWidget {
  final String title;
  final Color tableColor;
  final List<DailyEntry> initialEntries;

  const OfficePage({
    super.key,
    required this.title,
    required this.tableColor,
    required this.initialEntries,
  });

  @override
  State<OfficePage> createState() => _OfficePagePageState();
}

class _OfficePagePageState extends State<OfficePage> {
  List<DailyEntry> officeEntries = [];

  @override
  void initState() {
    super.initState();
    __loadofficeEntries();
  }

  Future<void> __loadofficeEntries() async {
    final prefs = await SharedPreferences.getInstance();

    // تحميل البيانات المخزنة مسبقاً
    List<String>? storedEntries = prefs.getStringList('officeEntries');

    if (storedEntries != null) {
      // فك ترميز البيانات المحفوظة وتحويلها إلى كائنات DailyEntry
      List<DailyEntry> oldEntries = storedEntries
          .map((entry) => DailyEntry.fromJson(jsonDecode(entry)))
          .toList();

      // دمج البيانات القديمة مع البيانات الجديدة
      setState(() {
        officeEntries = oldEntries + widget.initialEntries;
      });
    } else {
      // إذا لم تكن هناك بيانات محفوظة، استخدم البيانات الجديدة فقط
      setState(() {
        officeEntries = widget.initialEntries;
      });
    }

    // حفظ البيانات الجديدة
    _officeEntriesEntries();
  }

  Future<void> _officeEntriesEntries() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> entries = officeEntries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList('officeEntries', entries); // حفظ جميع البيانات
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.tableColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                  headingRowColor: MaterialStateProperty.all(widget.tableColor),
                  columns: [
                    DataColumn(label: _buildCenteredText('الاسم', width: 150)),
                    DataColumn(label: _buildCenteredText('التاريخ', width: 100)),
                    DataColumn(label: _buildCenteredText('البيان', width: 150)),
                    DataColumn(label: _buildCenteredText('ذهب لنا')),
                    DataColumn(label: _buildCenteredText('سوري لنا')),
                    DataColumn(label: _buildCenteredText('ذهب له')),
                    DataColumn(label: _buildCenteredText('سوري له')),
                    DataColumn(label: _buildCenteredText('الزبون')),
                  ],
                  rows: officeEntries.map((entry) {
                    return DataRow(cells: [
                      DataCell(_buildCenteredText(entry.name)),
                      DataCell(_buildCenteredText(DateFormat('yyyy-MM-dd').format(entry.date))),
                      DataCell(_buildCenteredText(entry.notes)),
                      DataCell(_buildCenteredText(entry.goldForUs.toString())),
                      DataCell(_buildCenteredText(entry.syrianForUs.toString())),
                      DataCell(_buildCenteredText(entry.goldForHim.toString())),
                      DataCell(_buildCenteredText(entry.syrianForHim.toString())),
                      DataCell(_buildCenteredText(entry.customer)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
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
