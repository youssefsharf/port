import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/add.dart';
import '../../data/entity/daily_entity.dart';

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

  // دالة لتحميل المدخلات
  void _loadEntries(List<DailyEntry> newEntries) {
    setState(() {
      dailyEntries = newEntries;
      isDataLoaded = true;
    });
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
                  columnSpacing: 20, // زيادة التباعد بين الأعمدة
                  horizontalMargin: 12, // المسافة بين النصوص والحواف
                  headingRowHeight: 60, // ارتفاع رأس الجدول
                  dataRowHeight: 60, // ارتفاع صفوف البيانات
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  border: TableBorder.all(
                    color: Colors.grey.shade400,
                    width: 1, // عرض الخطوط بين الخلايا
                    borderRadius: BorderRadius.circular(8),
                  ),
                  headingRowColor: MaterialStateProperty.all(widget.tableColor),
                    columns: [
                      DataColumn(
                        label: Container(
                          padding: const EdgeInsets.all(18.0),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown, // تغيير حجم النص ليتم تناسبه مع المساحة
                              child: Text(
                                'الاسم',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown, // تغيير حجم النص ليتم تناسبه مع المساحة
                            child: Text(
                              'التاريخ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown, // تغيير حجم النص ليتم تناسبه مع المساحة
                              child: Text(
                                'البيان',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown, // تغيير حجم النص ليتم تناسبه مع المساحة
                            child: Text(
                              'ذهب لنا',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown, // تغيير حجم النص ليتم تناسبه مع المساحة
                              child: Text(
                                'سوري لنا',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown, // تغيير حجم النص ليتم تناسبه مع المساحة
                            child: Text(
                              'ذهب له',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown, // تغيير حجم النص ليتم تناسبه مع المساحة
                              child: Text(
                                'سوري له',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // إضافة عمود للـ Notes
                    ],


                  rows: dailyEntries.map((entry) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown, // تغيير حجم النص ليتم تناسبه مع المساحة
                              child: Text(
                                entry.name,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown, // تغيير حجم النص ليتم تناسبه مع المساحة
                              child: Text(
                                DateFormat('yyyy-MM-dd').format(entry.date),
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown, // تغيير حجم النص ليتم تناسبه مع المساحة
                              child: Text(
                                entry.notes,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown, // تغيير حجم النص ليتم تناسبه مع المساحة
                              child: Text(
                                entry.goldForUs.toString(),
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown, // تغيير حجم النص ليتم تناسبه مع المساحة
                              child: Text(
                                entry.syrianForUs.toString(),
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown, // تغيير حجم النص ليتم تناسبه مع المساحة
                              child: Text(
                                entry.goldForHim.toString(),
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown, // تغيير حجم النص ليتم تناسبه مع المساحة
                              child: Text(
                                entry.syrianForHim.toString(),
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            )
                : Center(
              child: Text(
                'لا توجد مدخلات حالياً',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0, right: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // زر إضافة مدخلات
            FloatingActionButton(
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
                      },
                    );
                  },
                );
              },
              backgroundColor: widget.tableColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
