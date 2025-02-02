import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/widgets/export.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/models/daily_entity.dart';
import '../../../debts/presentation/pages/debts.dart';
import '../../../office/presentation/pages/office.dart';
import '../../../workshop/presentation/pages/workshop.dart';
import 'customerInfoPage.dart';

class SharedPreferencesHelper {
  static const String _nameKey = 'names';

  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> names = await loadNames();
    if (!names.contains(name)) {
      names.add(name);
      await prefs.setStringList(_nameKey, names);
    }
  }

  static Future<List<String>> loadNames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_nameKey) ?? [];
  }
}

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
  String _customer = '';
  DateTime _selectedDate = DateTime.now();
  String _selectedFilterCustomer = '';
  String _nameFilter = '';
  bool _isNewCustomer = false;
  DailyEntry? _editingEntry;
  int? _editingIndex;

  double get totalGoldForUs =>
      dailyEntries.fold(0, (sum, entry) => sum + entry.goldForUs);
  double get totalGoldForHim =>
      dailyEntries.fold(0, (sum, entry) => sum + entry.goldForHim);

  @override
  void initState() {
    super.initState();
    dailyEntries = widget.initialEntries;
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => isDataLoaded = false);
    dailyEntries = await dataManager.loadEntries();
    setState(() => isDataLoaded = true);
  }

  Future<void> _saveEntry() async {
    if (_nameController.text.isEmpty ||
        _noteController.text.isEmpty ||
        _goldForUsController.text.isEmpty ||
        _goldForHimController.text.isEmpty ||
        _customer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء ملء جميع الحقول')),
      );
      return;
    }

    // Save name in SharedPreferences
    SharedPreferencesHelper.saveName(_nameController.text);

    double goldForUs = double.tryParse(_goldForUsController.text) ?? 0;
    double goldForHim = double.tryParse(_goldForHimController.text) ?? 0;

    final newEntry = DailyEntry(
      name: _nameController.text,
      notes: _noteController.text,
      goldForUs: goldForUs,
      goldForHim: goldForHim,
      customer: _customer,
      date: _selectedDate,
      tableColor: widget.tableColor,
      customerInfo: _isNewCustomer ? _customerController.text : '',
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

    await dataManager.saveEntry(newEntry);

    // تفريغ الحقول بعد الحفظ
    _nameController.clear();
    _noteController.clear();
    _goldForUsController.clear();
    _goldForHimController.clear();
    _customerController.clear();
    _customer = '';
    _selectedDate = DateTime.now(); // إعادة تعيين التاريخ إلى التاريخ الحالي
    _isNewCustomer = false; // إعادة تعيين حالة الزبون الجديد

    // إعادة تعيين حالة التعديل
    setState(() {
      _editingEntry = null;
      _editingIndex = null;
    });
  }

  Future<void> _exportData() async {
    List<DailyEntry> workshopEntries = dailyEntries.where((entry) => entry.customer == 'ورشة').toList();
    List<DailyEntry> officeEntries = dailyEntries.where((entry) => entry.customer == 'مكتب').toList();
    List<DailyEntry> debtsEntries = dailyEntries.where((entry) => entry.customer == 'ذمم').toList();

    if (workshopEntries.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkShopPage(
            title: 'الورشة',
            tableColor: widget.tableColor,
            initialEntries: workshopEntries,
          ),
        ),
      );
    }

    if (debtsEntries.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DebtsPage(
            title: 'الذمم',
            tableColor: widget.tableColor,
            initialEntries: debtsEntries,
          ),
        ),
      );
    }

    if (officeEntries.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OfficePage(
            title: 'المكتب',
            tableColor: widget.tableColor,
            initialEntries: officeEntries,
          ),
        ),
      );
    }

    setState(() {
      dailyEntries.removeWhere((entry) =>
      entry.customer == 'ورشة' ||
          entry.customer == 'ذمم' ||
          entry.customer == 'مكتب');
    });

    await dataManager.updateEntries(dailyEntries);
  }

  @override
  Widget build(BuildContext context) {
    List<DailyEntry> filteredEntries = dailyEntries.where((entry) {
      bool matchesCustomerFilter = _selectedFilterCustomer.isEmpty || entry.customer == _selectedFilterCustomer;
      bool matchesNameFilter = _nameFilter.isEmpty || entry.name.contains(_nameFilter);
      return matchesCustomerFilter && matchesNameFilter;
    }).toList();

    filteredEntries.sort((a, b) => a.date.compareTo(b.date));
    filteredEntries = filteredEntries.reversed.toList();

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
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButton<String>(
                            value: _selectedFilterCustomer.isEmpty ? null : _selectedFilterCustomer,
                            hint: Text("اختر الزبون للتصفية"),
                            items: <String>['', 'ورشة', 'مكتب', 'ذمم']
                                .map((value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                                .toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedFilterCustomer = newValue!;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10),
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
                            headingRowColor: MaterialStateProperty.all(widget.tableColor),
                            columns: [
                              DataColumn(label: buildCenteredText('الاسم', width: 150)),
                              DataColumn(label: buildCenteredText('التاريخ', width: 100)),
                              DataColumn(label: buildCenteredText('البيان', width: 150)),
                              DataColumn(label: buildCenteredText('ذهب لنا')),
                              DataColumn(label: buildCenteredText('ذهب له')),
                              DataColumn(label: buildCenteredText('مكان الفاتوره')),
                              if (_isNewCustomer) DataColumn(label: buildCenteredText('معلومات الزبون')),
                              DataColumn(label: buildCenteredText('الاجراءات')),
                            ],
                            rows: [
                              DataRow(cells: [
                                DataCell(
                                  Center(
                                    child: Autocomplete<String>(
                                      optionsBuilder: (TextEditingValue textEditingValue) async {
                                        if (textEditingValue.text.isEmpty) {
                                          return const Iterable<String>.empty(); // لا تظهر اقتراحات إذا كان الحقل فارغًا
                                        }

                                        List<String> savedNames = await SharedPreferencesHelper.loadNames();
                                        final names = savedNames.toSet().toList();
                                        return names.where((option) =>
                                            option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                                      },
                                      onSelected: (String selection) {
                                        // لا تقم بتعبئة _nameController تلقائيًا هنا
                                      },
                                      fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                                        return SizedBox(
                                          width: 150, // عرض حقل النص
                                          child: TextField(
                                            controller: fieldTextEditingController,
                                            focusNode: fieldFocusNode,
                                            decoration: InputDecoration(
                                              labelText: 'الاسم',
                                              border: OutlineInputBorder(),
                                            ),
                                            onChanged: (value) {
                                              // تحديث _nameController عند تغيير النص يدويًا
                                              _nameController.text = value;
                                            },
                                          ),
                                        );
                                      },
                                      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                                        return Align(
                                          alignment: Alignment.topRight, // محاذاة الاقتراحات أسفل حقل النص
                                          child: Material(
                                            elevation: 4, // إضافة ظل لتحسين الرؤية
                                            child: SizedBox(
                                              width: 150, // نفس عرض حقل النص
                                              child: ListView.builder(
                                                padding: EdgeInsets.all(0),
                                                itemCount: options.length,
                                                shrinkWrap: true,
                                                itemBuilder: (BuildContext context, int index) {
                                                  final String option = options.elementAt(index);
                                                  return GestureDetector(
                                                    onTap: () {
                                                      onSelected(option); // اختيار الاقتراح
                                                    },
                                                    child: ListTile(
                                                      title: Text(
                                                        '$option', // عرض الاقتراح
                                                        textAlign: TextAlign.center, // محاذاة النص في المنتصف
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
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
                                    child: Center(child: buildCenteredText(DateFormat('yyyy-MM-dd').format(_selectedDate))),
                                  ),
                                ),
                                DataCell(Center(child: buildTextField(_noteController, 'البيان'))),
                                DataCell(Center(child: buildTextField(_goldForUsController, 'ذهب لنا', isNumber: true))),
                                DataCell(Center(child: buildTextField(_goldForHimController, 'ذهب له', isNumber: true))),
                                DataCell(
                                  Center(
                                    child: DropdownButton<String>(
                                      value: _customer.isEmpty ? null : _customer,
                                      hint: Text("اختر المكان"),
                                      items: <String>['ورشة', 'مكتب', 'ذمم'].map((value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Center( // Center the text inside each DropdownMenuItem
                                            child: Text(value),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          _customer = newValue!;
                                          _isNewCustomer = !dailyEntries.any((entry) => entry.customer == _customer);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                if (_isNewCustomer)
                                  DataCell(Center(child: TextField(
                                    controller: _customerController,
                                    decoration: InputDecoration(hintText: "معلومات الزبون", border: OutlineInputBorder()),
                                  ))),
                                DataCell(Center(child: ElevatedButton(
                                  onPressed: _saveEntry,
                                  child: Text(_editingEntry != null ? 'حفظ' : 'إضافة'),
                                ))),
                              ]),
                              ...filteredEntries.map((entry) {
                                return DataRow(cells: [
                                  DataCell(buildCenteredText(entry.name)),
                                  DataCell(buildCenteredText(DateFormat('yyyy-MM-dd').format(entry.date))),
                                  DataCell(buildCenteredText(entry.notes)),
                                  DataCell(buildCenteredText(entry.goldForUs.toString())),
                                  DataCell(buildCenteredText(entry.goldForHim.toString())),
                                  DataCell(buildCenteredText(entry.customer)),
                                  if (_isNewCustomer) DataCell(buildCenteredText(entry.customerInfo)),
                                  DataCell(Row(
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
                                            _isNewCustomer = !dailyEntries.any((e) => e.customer == _customer);
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
                                  )),
                                ]);
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("مجموع ذهب لنا: ${totalGoldForUs.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(width: 20),
                          Text("مجموع ذهب له: ${totalGoldForHim.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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