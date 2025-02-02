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
  String? selectedName;
  DateTime? selectedDate;
  List<String> availableNames = [];

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
      List<DailyEntry> oldEntries = storedEntries
          .map((entry) => DailyEntry.fromJson(jsonDecode(entry)))
          .toList();

      setState(() {
        debtsEntries = oldEntries + widget.initialEntries;
        // ترتيب الإدخالات من الأحدث إلى الأقدم
        debtsEntries.sort((a, b) => b.date.compareTo(a.date));
        filteredEntries = debtsEntries;
        availableNames = debtsEntries.map((entry) => entry.name).toSet().toList();
      });
    } else {
      setState(() {
        debtsEntries = widget.initialEntries;
        debtsEntries.sort((a, b) => b.date.compareTo(a.date)); // ترتيب من الأحدث للأقدم
        filteredEntries = debtsEntries;
        availableNames = debtsEntries.map((entry) => entry.name).toSet().toList();
      });
    }

    _saveDebtsEntries();
  }

  Future<void> _saveDebtsEntries() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> entries = debtsEntries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList('debtsEntries', entries);
  }

  double get totalGoldForUs => filteredEntries.fold(0, (sum, entry) => sum + entry.goldForUs);
  double get totalGoldForHim => filteredEntries.fold(0, (sum, entry) => sum + entry.goldForHim);

  void _filterEntriesByName(String? name) {
    setState(() {
      if (name == null || name.isEmpty) {
        filteredEntries = debtsEntries;
      } else {
        filteredEntries = debtsEntries.where((entry) {
          return entry.name == name;
        }).toList();
      }
      filteredEntries.sort((a, b) => b.date.compareTo(a.date)); // ترتيب من الأحدث للأقدم
    });
  }

  void _filterEntriesByDate(DateTime? date) {
    setState(() {
      if (date == null) {
        filteredEntries = debtsEntries;
      } else {
        filteredEntries = debtsEntries.where((entry) {
          return DateFormat('yyyy-MM-dd').format(entry.date) ==
              DateFormat('yyyy-MM-dd').format(date);
        }).toList();
      }
      filteredEntries.sort((a, b) => b.date.compareTo(a.date)); // ترتيب من الأحدث للأقدم
    });
  }


  void _showNamePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: availableNames.map((name) {
            return ListTile(
              title: Text(name),
              onTap: () {
                setState(() {
                  selectedName = name;
                  _filterEntriesByName(selectedName); // تصفية الإدخالات بناءً على الاسم فقط
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showNamePicker(context),
                      child: Text(
                        selectedName == null ? "اختر الاسم" : selectedName!,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                            _filterEntriesByDate(selectedDate);
                          });
                        }
                      },
                      child: Text(
                        selectedDate == null
                            ? "اختر التاريخ"
                            : DateFormat('yyyy-MM-dd').format(selectedDate!),
                      ),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
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
                        DataColumn(label: _buildCenteredText('التاريخ', width: 100)),
                        DataColumn(label: _buildCenteredText('البيان', width: 150)),
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "مجموع ذهب لنا: ${totalGoldForUs.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 20),
                      Text(
                        "مجموع ذهب له: ${totalGoldForHim.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
