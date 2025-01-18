import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../../../../data/daily_entity.dart';
import '../../../debts/presentation/pages/debts.dart';
import '../../../office/presentation/pages/office.dart';
import '../../../workshop/presentation/pages/workshop.dart';

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

  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _goldForUsController = TextEditingController();
  final _syrianForUsController = TextEditingController();
  final _goldForHimController = TextEditingController();
  final _syrianForHimController = TextEditingController();
  String _customer = ''; // حفظ القيمة المحددة للزبون
  DateTime _selectedDate = DateTime.now();

  DailyEntry? _editingEntry;
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

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

  Future<void> _updateEntries() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> entries = dailyEntries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList('dailyEntries', entries);
  }

  Future<void> _saveEntry() async {
    if (_nameController.text.isEmpty ||
        _noteController.text.isEmpty ||
        _goldForUsController.text.isEmpty ||
        _syrianForUsController.text.isEmpty ||
        _goldForHimController.text.isEmpty ||
        _syrianForHimController.text.isEmpty ||
        _customer.isEmpty) { // التحقق من إدخال الزبون
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('الرجاء ملء جميع الحقول')));
      return;
    }

    double goldForUs = double.tryParse(_goldForUsController.text) ?? 0;
    double syrianForUs = double.tryParse(_syrianForUsController.text) ?? 0;
    double goldForHim = double.tryParse(_goldForHimController.text) ?? 0;
    double syrianForHim = double.tryParse(_syrianForHimController.text) ?? 0;

    final newEntry = DailyEntry(
      name: _nameController.text,
      notes: _noteController.text,
      goldForUs: goldForUs,
      syrianForUs: syrianForUs,
      goldForHim: goldForHim,
      syrianForHim: syrianForHim,
      customer: _customer, // استخدام القيمة المحددة للزبون
      date: _selectedDate,
      tableColor: widget.tableColor,
    );

    if (_editingEntry != null && _editingIndex != null) {
      setState(() {
        dailyEntries[_editingIndex!] = newEntry;
        _editingEntry = null;
        _editingIndex = null;
      });
    } else {
      setState(() {
        dailyEntries.add(newEntry);
      });
    }

    await _updateEntries();

    _nameController.clear();
    _noteController.clear();
    _goldForUsController.clear();
    _syrianForUsController.clear();
    _goldForHimController.clear();
    _syrianForHimController.clear();
    _customer = ''; // مسح حقل الزبون
  }

  // Export data to a file (e.g., CSV or JSON)
  Future<void> _exportData() async {
    // تصفية البيانات لاختيار مدخلات الزبون "ورشة" و "مكتب"
    List<DailyEntry> workshopEntries = dailyEntries.where((entry) => entry.customer == 'ورشة').toList();
    List<DailyEntry> officeEntries = dailyEntries.where((entry) => entry.customer == 'مكتب').toList();
    List<DailyEntry> debtsEntries = dailyEntries.where((entry) => entry.customer == 'ذمم').toList();


    // حدد الصفحة التي سيتم الانتقال إليها بناءً على نوع البيانات
    if (workshopEntries.isNotEmpty) {
      // انتقل إلى صفحة ورشة العمل مع المدخلات المصفاة
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkShopPage(
            title: 'ورشة العمل',
            tableColor: widget.tableColor,
            initialEntries: workshopEntries,
          ),
        ),
      );

      // إزالة المدخلات "ورشة" من قائمة dailyEntries
      setState(() {
        dailyEntries.removeWhere((entry) => entry.customer == 'ورشة');
      });
    }
    if (debtsEntries.isNotEmpty) {
      // انتقل إلى صفحة ورشة العمل مع المدخلات المصفاة
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DebtsPage(
            title: 'ذمم ',
            tableColor: widget.tableColor,
            initialEntries: debtsEntries,
          ),
        ),
      );

      // إزالة المدخلات "ورشة" من قائمة dailyEntries
      setState(() {
        dailyEntries.removeWhere((entry) => entry.customer == 'ذمم');
      });
    }


    if (officeEntries.isNotEmpty) {
      // انتقل إلى صفحة المكتب مع المدخلات المصفاة
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OfficePage(
            title: 'المكتب',
            tableColor: widget.tableColor,
            initialEntries: officeEntries,
          ),
        ),
      );

      // إزالة المدخلات "مكتب" من قائمة dailyEntries
      setState(() {
        dailyEntries.removeWhere((entry) => entry.customer == 'مكتب');
      });
    }

    // تحديث SharedPreferences بعد إزالة المدخلات المصدرة
    await _updateEntries();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
        title: Padding(
        padding: const EdgeInsets.only(left: 83.0),
    child: Text("دفتر اليوميه"),
    ),
    backgroundColor: widget.tableColor,
    elevation: 100,
    ),
    body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: SingleChildScrollView(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    const SizedBox(height: 20),
    if (isDataLoaded)
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
    child: SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: Container(
    width: MediaQuery.of(context).size.width, // Ensure that width is respected
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
      DataColumn(label: _buildCenteredText('الاجراءات')),
      ],
      rows: [
      DataRow(cells: [
      DataCell(
      Center(
      child: _buildTextField(_nameController, 'الاسم'),
      ),
      ),
      DataCell(
      GestureDetector(
      onTap: () async {
      final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      );
      if (picked != null && picked != _selectedDate) {
      setState(() {
      _selectedDate = picked;
      });
      }
      },
      child: Center(
      child: _buildCenteredText(
      DateFormat('yyyy-MM-dd').format(_selectedDate)),
      ),
      ),
      ),
      DataCell(
      Center(
      child: _buildTextField(_noteController, 'البيان'),
      ),
      ),
      DataCell(
      Center(
      child: _buildTextField(_goldForUsController, 'ذهب لنا',
      isNumber: true),
      ),
      ),
      DataCell(
      Center(
      child: _buildTextField(_syrianForUsController, 'سوري لنا',
      isNumber: true),
      ),
      ),
      DataCell(
      Center(
      child: _buildTextField(_goldForHimController, 'ذهب له',
      isNumber: true),
      ),
      ),
      DataCell(
      Center(
      child: _buildTextField(_syrianForHimController, 'سوري له',
      isNumber: true),
      ),
      ),
      DataCell(
      Center(
      child: DropdownButton<String>(
      value: _customer.isEmpty ? null : _customer,
      hint: Text("اختر الزبون"),
      items: <String>['ورشة', 'مكتب', 'ذمم']
          .map((String value) {
      return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
      );
      }).toList(),
      onChanged: (String? newValue) {
      setState(() {
      _customer = newValue!;
      });
      },
      ),
      ),
      ),
      DataCell(
      Center(
      child: ElevatedButton(
      onPressed: _saveEntry,
      child: Text(_editingEntry != null ? 'حفظ' : 'إضافة'),
      ),
      ),
      ),
      ]),
      ...dailyEntries.map((entry) {
      return DataRow(cells: [
      DataCell(_buildCenteredText(entry.name)),
      DataCell(_buildCenteredText(
      DateFormat('yyyy-MM-dd').format(entry.date))),
      DataCell(_buildCenteredText(entry.notes)),
      DataCell(_buildCenteredText(entry.goldForUs.toString())),
      DataCell(_buildCenteredText(entry.syrianForUs.toString())),
      DataCell(_buildCenteredText(entry.goldForHim.toString())),
      DataCell(_buildCenteredText(entry.syrianForHim.toString())),
      DataCell(_buildCenteredText(entry.customer)),
      DataCell(
      Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      IconButton(
      icon: Icon(Icons.edit, color: Colors.blue),
      onPressed: () {
      setState(() {
      _editingEntry = entry;
      _editingIndex = dailyEntries.indexOf(entry);

      _nameController.text = entry.name;
      _noteController.text = entry.notes;
      _goldForUsController.text =
      entry.goldForUs.toString();
      _syrianForUsController.text =
      entry.syrianForUs.toString();
      _goldForHimController.text =
      entry.goldForHim.toString();
      _syrianForHimController.text =
      entry.syrianForHim.toString();
      _customer = entry.customer;
      _selectedDate = entry.date;
      });
      },
      ),
      IconButton(
      icon: Icon(Icons.delete, color: Colors.red),
      onPressed: () {
      setState(() {
      dailyEntries.remove(entry);
      _updateEntries();
      });
      },
      ),
      ],
      ),
      ),
      ]);
      }).toList(),
      ],
      ),
    ),
    ),
    ),
    )
    else
    Center(child: CircularProgressIndicator()),
    Padding(
    padding: const EdgeInsets.symmetric(vertical: 20.0),
    child: ElevatedButton(
    onPressed: _exportData,
    child: Text('تصدير البيانات'),
    ),
    ),
    ],
    ),
    ),
    ));
  }

  Widget _buildCenteredText(String text, {double width = 120}) {
    return Container(
      width: width,
      child: Center(child: Text(text)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }
}
