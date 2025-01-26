import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/widgets/export.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/models/daily_entity.dart';
import '../../../debts/presentation/pages/debts.dart';
import '../../../office/presentation/pages/office.dart';
import '../../../workshop/presentation/pages/workshop.dart';
import 'ff.dart';

class DailyPage extends StatefulWidget {
  final String title;
  final Color tableColor;
  final List<DailyEntry> initialEntries;

  const DailyPage({
    super.key,
    required this.title,
    required this.tableColor,
    required this.initialEntries,
  });

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  List<DailyEntry> dailyEntries = [];
  bool isDataLoaded = false;
  final dataManager = DataManager();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _goldForUsController = TextEditingController();
  final _goldForHimController = TextEditingController();
  final _customerController = TextEditingController();
  String _customer = ''; // حفظ القيمة المحددة للزبون
  DateTime _selectedDate = DateTime.now();
  String _selectedFilterCustomer = ''; // فلتر الزبون
  String _nameFilter = ''; // فلتر الاسم
  bool _isNewCustomer = false; // لتتبع حالة الزبون

  DailyEntry? _editingEntry;
  int? _editingIndex;

  double get totalGoldForUs => dailyEntries.fold(0, (sum, entry) => sum + entry.goldForUs);
  double get totalGoldForHim => dailyEntries.fold(0, (sum, entry) => sum + entry.goldForHim);

  @override
  void initState() {
    super.initState();
    dailyEntries = widget.initialEntries;
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      isDataLoaded = false;
    });

    // تحميل المدخلات باستخدام DataManager
    List<DailyEntry> entries = await dataManager.loadEntries();

    setState(() {
      dailyEntries = entries;
      isDataLoaded = true;
    });
  }

  Future<void> _saveEntry() async {
    if (_nameController.text.isEmpty ||
        _noteController.text.isEmpty ||
        _goldForUsController.text.isEmpty ||
        _goldForHimController.text.isEmpty ||
        _customer.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('الرجاء ملء جميع الحقول')));
      return;
    }

    double goldForUs = double.tryParse(_goldForUsController.text) ?? 0;
    double goldForHim = double.tryParse(_goldForHimController.text) ?? 0;

    // التحقق مما إذا كان الزبون موجودًا مسبقًا
    bool isCustomerExisting = dailyEntries.any((entry) => entry.customer == _customer);

    setState(() {
      _isNewCustomer = !isCustomerExisting; // تحديث حالة الزبون
    });

    final newEntry = DailyEntry(
      name: _nameController.text,
      notes: _noteController.text,
      goldForUs: goldForUs,
      goldForHim: goldForHim,
      customer: _customer,
      date: _selectedDate,
      tableColor: widget.tableColor,
      customerInfo: _isNewCustomer ? _customerController.text : '', // حفظ معلومات الزبون إذا كان جديدًا
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

    // حفظ المدخلات باستخدام DataManager
    await dataManager.saveEntry(newEntry);

    // مسح الحقول بعد الحفظ
    _nameController.clear();
    _noteController.clear();
    _goldForUsController.clear();
    _goldForHimController.clear();
    _customerController.clear();
    _customer = ''; // مسح حقل الزبون
  }

  // دالة لتصدير البيانات
  Future<void> _exportData() async {
    // تصفية البيانات حسب الزبون
    List<DailyEntry> workshopEntries =
    dailyEntries.where((entry) => entry.customer == 'ورشة').toList();
    List<DailyEntry> officeEntries =
    dailyEntries.where((entry) => entry.customer == 'مكتب').toList();
    List<DailyEntry> debtsEntries =
    dailyEntries.where((entry) => entry.customer == 'ذمم').toList();

    if (workshopEntries.isNotEmpty) {
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
      setState(() {
        dailyEntries.removeWhere((entry) => entry.customer == 'ورشة');
      });
    }
    if (debtsEntries.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DebtsPage(
            title: 'ذمم',
            tableColor: widget.tableColor,
            initialEntries: debtsEntries,
          ),
        ),
      );
      setState(() {
        dailyEntries.removeWhere((entry) => entry.customer == 'ذمم');
      });
    }
    if (officeEntries.isNotEmpty) {
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
      setState(() {
        dailyEntries.removeWhere((entry) => entry.customer == 'مكتب');
      });
    }
    if (officeEntries.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerInfoPage(
            title: 'معلومات الزبون', // عنوان الصفحة
            tableColor: widget.tableColor, // لون الجدول
            customerEntries: officeEntries, // قائمة المدخلات
          ),
        ),
      );
      setState(() {
        dailyEntries.removeWhere((entry) => entry.customer == 'مكتب'); // إزالة المدخلات من القائمة الرئيسية
      });
    }
    // تحديث المدخلات في SharedPreferences بعد التصدير
    await dataManager.updateEntries(dailyEntries);
  }

  @override
  Widget build(BuildContext context) {
    // تصفية المدخلات حسب الزبون المحدد
    List<DailyEntry> filteredEntries = dailyEntries.where((entry) {
      bool matchesCustomerFilter = _selectedFilterCustomer.isEmpty ||
          entry.customer == _selectedFilterCustomer;
      bool matchesNameFilter = _nameFilter.isEmpty ||
          entry.name.contains(_nameFilter);

      return matchesCustomerFilter && matchesNameFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 83.0),
          child: Text("دفتر اليوميه"),
        ),
        backgroundColor: widget.tableColor,
        elevation: 100,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // صف يحتوي على حقل الفلترة وحقل البحث
                    Row(
                      children: [
                        // حقل الفلترة
                        Expanded(
                          flex: 2,
                          child: DropdownButton<String>(
                            value: _selectedFilterCustomer.isEmpty
                                ? null
                                : _selectedFilterCustomer,
                            hint: Text("اختر الزبون للتصفية"),
                            items: <String>['', 'ورشة', 'مكتب', 'ذمم']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedFilterCustomer = newValue!;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10), // مسافة بين العنصرين
                        // حقل البحث
                        Expanded(
                          flex: 3,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _nameFilter = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'ابحث بالاسم',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (isDataLoaded)
                      SingleChildScrollView(
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
                              DataColumn(label: buildCenteredText('الاسم', width: 150)),
                              DataColumn(label: buildCenteredText('التاريخ', width: 100)),
                              DataColumn(label: buildCenteredText('البيان', width: 150)),
                              DataColumn(label: buildCenteredText('ذهب لنا')),
                              DataColumn(label: buildCenteredText('ذهب له')),
                              DataColumn(label: buildCenteredText('الزبون')),
                              if (_isNewCustomer) // إظهار العمود فقط إذا كان الزبون جديدًا
                                DataColumn(label: buildCenteredText('معلومات الزبون')),
                              DataColumn(label: buildCenteredText('الاجراءات')),
                            ],
                            rows: [
                              DataRow(cells: [
                                DataCell(
                                  Center(
                                    child: buildTextField(_nameController, 'الاسم'),
                                  ),
                                ),
                                DataCell(
                                  GestureDetector(
                                    onTap: () async {
                                      final DateTime? picked =
                                      await showDatePicker(
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
                                      child: buildCenteredText(
                                          DateFormat('yyyy-MM-dd')
                                              .format(_selectedDate)),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: buildTextField(_noteController, 'البيان'),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: buildTextField(
                                        _goldForUsController, 'ذهب لنا',
                                        isNumber: true),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: buildTextField(
                                        _goldForHimController, 'ذهب له',
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
                                          // التحقق مما إذا كان الزبون موجودًا مسبقًا
                                          _isNewCustomer = !dailyEntries.any((entry) => entry.customer == _customer);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                if (_isNewCustomer) // إظهار الخلية فقط إذا كان الزبون جديدًا
                                  DataCell(
                                    Center(
                                      child: TextField(
                                        controller: _customerController,
                                        decoration: InputDecoration(
                                          hintText: "معلومات الزبون",
                                          border: OutlineInputBorder(),
                                        ),
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
                              // عرض البيانات المفلترة
                              ...filteredEntries.map((entry) {
                                return DataRow(cells: [
                                  DataCell(buildCenteredText(entry.name)),
                                  DataCell(buildCenteredText(DateFormat('yyyy-MM-dd').format(entry.date))),
                                  DataCell(buildCenteredText(entry.notes)),
                                  DataCell(buildCenteredText(entry.goldForUs.toString())),
                                  DataCell(buildCenteredText(entry.goldForHim.toString())),
                                  DataCell(buildCenteredText(entry.customer)),
                                  if (_isNewCustomer) // إظهار الخلية فقط إذا كان الزبون جديدًا
                                    DataCell(buildCenteredText(entry.customerInfo)),
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
                                              _goldForUsController.text = entry.goldForUs.toString();
                                              _goldForHimController.text = entry.goldForHim.toString();
                                              _customer = entry.customer;
                                              _selectedDate = entry.date;
                                              _customerController.text = entry.customerInfo;
                                              _isNewCustomer = !dailyEntries.any((e) => e.customer == _customer); // تحديث حالة الزبون
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              dailyEntries.remove(entry);
                                              dataManager.updateEntries(dailyEntries);
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
                    // عرض مجموع الذهب
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _exportData,
                    child: Text("تصدير البيانات"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}