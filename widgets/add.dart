import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // استيراد مكتبة json
import '../../features/dialy/data/entity/daily_entity.dart';

class AddDailyEntryDialog extends StatefulWidget {
  final void Function(DailyEntry) onEntrySaved;
  final Color tableColor;

  const AddDailyEntryDialog({
    super.key,
    required this.onEntrySaved,
    required this.tableColor,
  });

  @override
  State<AddDailyEntryDialog> createState() => _AddDailyEntryDialogState();
}

class _AddDailyEntryDialogState extends State<AddDailyEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _goldForUsController = TextEditingController();
  final _syrianForUsController = TextEditingController();
  final _goldForHimController = TextEditingController();
  final _syrianForHimController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool isGoldForUsFilled = false;
  bool isSyrianForUsFilled = false;
  bool isGoldForHimFilled = false;
  bool isSyrianForHimFilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _goldForUsController.dispose();
    _syrianForUsController.dispose();
    _goldForHimController.dispose();
    _syrianForHimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text('إضافة مدخل يومي')),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center, // توسيط العناصر داخل العمود
                children: [
                  // السطر الأول: الاسم، التاريخ، البيان
                  _buildTextField(_nameController, 'الاسم'),
                  const SizedBox(height: 8.0),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: _selectedDate, // تحديد أول تاريخ قابل للاختيار ليكون اليوم الحالي
                        lastDate: _selectedDate,  // تحديد آخر تاريخ قابل للاختيار ليكون اليوم الحالي
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: _buildTextField(
                      TextEditingController(text: DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      'التاريخ',
                      enabled: false, // لمنع التعديل يدويًا
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  _buildTextField(_noteController, 'البيان'),
                  const SizedBox(height: 16.0),

                  // السطر الثاني: ذهب لنا، سوري لنا
                  _buildGoldInputField(_goldForUsController, 'ذهب لنا', (value) {
                    setState(() {
                      isGoldForUsFilled = value.isNotEmpty;
                    });
                  }),
                  const SizedBox(height: 8.0),
                  _buildGoldInputField(_syrianForUsController, 'سوري لنا', (value) {
                    setState(() {
                      isSyrianForUsFilled = value.isNotEmpty;
                    });
                  }),
                  const SizedBox(height: 16.0),

                  // السطر الثالث: ذهب له، سوري له
                  _buildGoldInputField(_goldForHimController, 'ذهب له', (value) {
                    setState(() {
                      isGoldForHimFilled = value.isNotEmpty;
                    });
                  }),
                  const SizedBox(height: 8.0),
                  _buildGoldInputField(_syrianForHimController, 'سوري له', (value) {
                    setState(() {
                      isSyrianForHimFilled = value.isNotEmpty;
                    });
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final name = _nameController.text;
              final notes = _noteController.text;
              final date = _selectedDate;

              double? goldForUs = double.tryParse(_goldForUsController.text);
              double? syrianForUs = double.tryParse(_syrianForUsController.text);
              double? goldForHim = double.tryParse(_goldForHimController.text);
              double? syrianForHim = double.tryParse(_syrianForHimController.text);

              if (goldForUs == null || syrianForUs == null || goldForHim == null || syrianForHim == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('الرجاء إدخال أرقام صحيحة في الحقول المطلوبة')),
                );
                return;
              }

              final prefs = await SharedPreferences.getInstance();
              int? id = prefs.getInt('lastEntryId') ?? 0;
              id++;
              await prefs.setInt('lastEntryId', id);

              Map<String, dynamic> entryData = {
                'name': name,
                'goldForUs': goldForUs.toString(),
                'syrianForUs': syrianForUs.toString(),
                'goldForHim': goldForHim.toString(),
                'syrianForHim': syrianForHim.toString(),
                'notes': notes,
                'date': date.toIso8601String(),
                'tableColor': widget.tableColor.value.toString(),
              };

              await prefs.setString('entry_$id', jsonEncode(entryData));

              widget.onEntrySaved(DailyEntry(
                name: name,
                goldForUs: goldForUs,
                syrianForUs: syrianForUs,
                goldForHim: goldForHim,
                syrianForHim: syrianForHim,
                notes: notes,
                date: date,
                tableColor: widget.tableColor,
              ));

              Navigator.pop(context);
            }
          },
          child: const Text('حفظ'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        textAlign: TextAlign.center, // توسيط النص داخل الحقل
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            textBaseline: TextBaseline.alphabetic, // لضمان التوسيط
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto, // تحريك الـlabel داخل الحقل
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        validator: (value) => value == null || value.isEmpty ? 'الرجاء إدخال $label' : null,
      ),
    );
  }

  Widget _buildGoldInputField(TextEditingController controller, String label, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.center, // توسيط النص داخل الحقل
        decoration: InputDecoration(
          labelText: label,

          labelStyle: TextStyle(

            textBaseline: TextBaseline.alphabetic,
            // لضمان التوسيط
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto, // تحريك الـlabel داخل الحقل
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) return 'الرجاء إدخال $label';
          if (double.tryParse(value) == null) return 'الرجاء إدخال رقم صحيح';
          return null;
        },
        onChanged: (value) {
          if (value.isNotEmpty && !value.startsWith('"') && !value.endsWith('"')) {
            onChanged('"$value"');
          } else {
            onChanged(value);
          }
        },
      ),
    );
  }}
