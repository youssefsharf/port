import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart'; // استيراد المكتبة
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
  DateTime? selectedDate; // تخزين التاريخ المختار

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now(); // تعيين التاريخ الحالي عند بدء الصفحة
    _loadDebtsEntries();
  }

  Future<void> _loadDebtsEntries() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedEntries = prefs.getStringList('debtsEntries');

    if (storedEntries != null) {
      List<DailyEntry> oldEntries = storedEntries
          .map((entry) => DailyEntry.fromJson(jsonDecode(entry)))
          .toList();

      setState(() {
        debtsEntries = oldEntries + widget.customerEntries;
        filteredEntries = debtsEntries;
        _filterByDate(selectedDate); // تصفية البيانات حسب التاريخ الحالي
      });
    } else {
      setState(() {
        debtsEntries = widget.customerEntries;
        filteredEntries = debtsEntries;
        _filterByDate(selectedDate); // تصفية البيانات حسب التاريخ الحالي
      });
    }

    _saveDebtsEntries();
  }

  Future<void> _saveDebtsEntries() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> entries =
        debtsEntries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList('debtsEntries', entries);
  }

  void _shareEntry(DailyEntry entry) {
    final String shareText =
        'الاسم: ${entry.name}\nالبيان: ${entry.notes}\nالتاريخ: ${DateFormat('yyyy-MM-dd').format(entry.date)}\nذهب لنا: ${entry.goldForUs}\nذهب له: ${entry.goldForHim}\nمعلومات الزبون: ${entry.customerInfo}';
    Share.share(shareText); // مشاركة البيانات
  }

  void _filterByDate(DateTime? date) {
    if (date != null) {
      setState(() {
        filteredEntries = debtsEntries
            .where((entry) =>
                DateFormat('yyyy-MM-dd').format(entry.date) ==
                DateFormat('yyyy-MM-dd').format(date))
            .toList();
      });
    } else {
      setState(() {
        filteredEntries = debtsEntries;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _filterByDate(picked); // تحديث الفلترة حسب التاريخ
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ترتيب العناصر من الأقدم إلى الأحدث
    filteredEntries.sort((a, b) => a.date.compareTo(b.date));

    // عكس الترتيب ليصبح من الأحدث إلى الأقدم
    filteredEntries = filteredEntries.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.tableColor,
        centerTitle: true,
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.3),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDate(context), // اختيار التاريخ
          ),
        ],
      ),
      body: Column(
        children: [
          if (selectedDate != null) // عرض التاريخ المختار
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "التاريخ المختار: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl, // التوجيه من اليمين لليسار
              child: ListView.builder(
                itemCount: filteredEntries.length,
                itemBuilder: (context, index) {
                  final entry = filteredEntries[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person,
                                  color: widget.tableColor, size: 24),
                              SizedBox(width: 8),
                              Text(
                                "الاسم: ${entry.name}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.description,
                                  color: widget.tableColor, size: 24),
                              SizedBox(width: 8),
                              Text(
                                "البيان: ${entry.notes}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.date_range,
                                  color: widget.tableColor, size: 24),
                              SizedBox(width: 8),
                              Text(
                                "التاريخ: ${DateFormat('yyyy-MM-dd').format(entry.date)}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.attach_money,
                                  color: widget.tableColor, size: 24),
                              SizedBox(width: 8),
                              Text(
                                "ذهب لنا: ${entry.goldForUs}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.attach_money,
                                  color: widget.tableColor, size: 24),
                              SizedBox(width: 8),
                              Text(
                                "ذهب له: ${entry.goldForHim}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.info,
                                  color: widget.tableColor, size: 24),
                              SizedBox(width: 8),
                              Text(
                                "معلومات الزبون: ${entry.customerInfo}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon:
                                    Icon(Icons.share, color: widget.tableColor),
                                onPressed: () {
                                  _shareEntry(entry); // استدعاء ميزة المشاركة
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
