import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? existing; // ถ้าส่งมา = โหมดแก้ไข
  const AddTransactionScreen({super.key, this.existing});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  static const _expenseCats = [
    'อาหาร', 'เดินทาง', 'ช้อปปิ้ง', 'บิล/ค่าใช้จ่าย', 'บันเทิง', 'อื่นๆ'
  ];
  static const _incomeCats = ['เงินเดือน', 'รายได้', 'เงินเก็บ', 'อื่นๆ'];

  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _type = 'expense';
  late String _category;
  DateTime _date = DateTime.now();
  bool _saving = false;

  List<String> get _cats => _type == 'income' ? _incomeCats : _expenseCats;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _type = e.type;
      _category = e.category;
      _date = e.date;
      _amountCtrl.text = e.amount.toString();
      _noteCtrl.text = e.note;
      if (!_cats.contains(_category)) _category = _cats.first;
        } else {
      _category = _cats.first;
      final m = context.read<TransactionProvider>().month;
      final now = DateTime.now();
      final lastDay = DateTime(m.year, m.month + 1, 0).day; // วันสุดท้ายของเดือนนั้น
      final day = now.day > lastDay ? lastDay : now.day;
      _date = DateTime(m.year, m.month, day, now.hour, now.minute, now.second);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final t = TransactionModel(
      id: widget.existing?.id,
      type: _type,
      amount: double.parse(_amountCtrl.text.replaceAll(',', '')),
      category: _category,
      note: _noteCtrl.text.trim(),
      date: _date,
    );

    final p = context.read<TransactionProvider>();
    try {
      if (widget.existing == null) {
        await p.add(t);
      } else {
        await p.update(t);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'แก้ไขรายการ' : 'เพิ่มรายการ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: 'expense',
                        label: Text('รายจ่าย'),
                        icon: Icon(Icons.arrow_downward)),
                    ButtonSegment(
                        value: 'income',
                        label: Text('รายรับ'),
                        icon: Icon(Icons.arrow_upward)),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() {
                    _type = s.first;
                    _category = _cats.first;
                  }),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'จำนวนเงิน (บาท)',
                  prefixIcon: Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', ''));
                  if (n == null || n <= 0) return 'กรุณากรอกจำนวนเงินที่มากกว่า 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'หมวดหมู่',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _cats
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'วันที่',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(DateFormat('d MMM yyyy').format(_date)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'โน้ต (ไม่บังคับ)',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('บันทึก'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}